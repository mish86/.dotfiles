#!/usr/bin/env bash

# AWS helpers (Git Bash on Windows).
# Requires: aws CLI, fzf, kubectl, jq, AWS Session Manager plugin.

command -v aws &>/dev/null || return 0
command -v fzf &>/dev/null || return 0

# Resolve AWS region or fail with a useful message.
# Usage: region=$(_aws_region <caller-name>) || return 1
_aws_region() {
  local r="${AWS_REGION:-${AWS_DEFAULT_REGION:-$(aws configure get region 2>/dev/null)}}"
  if [[ -z "$r" ]]; then
    echo "${1:-aws}: AWS region not set (export AWS_REGION or aws configure)" >&2
    return 1
  fi
  printf '%s\n' "$r"
}

# fzf-pick a running EC2 instance, print its InstanceId. Shows id, Name tag,
# private IP, and type, aligned in columns.
# Usage: instance=$(_aws_pick_ec2 "$region") || return 1
_aws_pick_ec2() {
  local region="$1"
  aws ec2 describe-instances --region "$region" \
      --filters 'Name=instance-state-name,Values=running' \
      --query 'Reservations[].Instances[].[InstanceId, (Tags[?Key==`Name`].Value | [0]) || `-`, PrivateIpAddress, InstanceType]' \
      --output text \
    | column -t \
    | fzf --prompt 'EC2> ' --no-multi --exit-0 --select-1 \
    | awk '{print $1}'
}

# eks-ssm-forward [LOCAL_PORT]
#   1. Pick an EKS cluster (fzf) and remember its API endpoint.
#   2. Refresh kubeconfig for it, then rewrite the cluster entry to
#      point at https://127.0.0.1:LOCAL_PORT with insecure-skip-tls-verify=true.
#   3. Pick a running EC2 bastion (fzf) and start an SSM port-forward
#      session that maps localhost:LOCAL_PORT -> <cluster endpoint>:443.
#
# LOCAL_PORT defaults to 443. Use a different port (e.g. 6443, 8443) to run
# parallel sessions against different clusters - each cluster's kubeconfig
# context will point at its own 127.0.0.1:<port>.
eks-ssm-forward() {
  local region cluster endpoint endpoint_host instance ctx
  local local_port="${1:-443}"

  if ! [[ "$local_port" =~ ^[0-9]+$ ]] || (( local_port < 1 || local_port > 65535 )); then
    echo "eks-ssm-forward: invalid local port '$local_port' (1-65535)" >&2
    return 1
  fi

  region=$(_aws_region eks-ssm-forward) || return 1

  for cmd in kubectl jq; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "eks-ssm-forward: missing required command: $cmd" >&2
      return 1
    fi
  done

  # 1. Pick EKS cluster
  cluster=$(aws eks list-clusters --region "$region" --query 'clusters[]' --output text \
    | tr '\t' '\n' \
    | fzf --prompt 'EKS cluster> ' --no-multi --exit-0 --select-1) || return 1
  [[ -z "$cluster" ]] && { echo "eks-ssm-forward: no cluster selected" >&2; return 1; }

  endpoint=$(aws eks describe-cluster --region "$region" --name "$cluster" \
    --query 'cluster.endpoint' --output text)
  if [[ -z "$endpoint" || "$endpoint" == "None" ]]; then
    echo "eks-ssm-forward: could not resolve endpoint for $cluster" >&2
    return 1
  fi
  endpoint_host="${endpoint#https://}"
  endpoint_host="${endpoint_host%%/*}"
  endpoint_host="${endpoint_host%%:*}"
  echo "eks-ssm-forward: cluster=$cluster endpoint=$endpoint"

  # 2. Update kubeconfig (with short alias) and rewrite cluster entry for the tunnel.
  # --alias makes the *context* name short (== the EKS cluster name). The
  # cluster entry inside kubeconfig still uses the ARN, so we look it up
  # before mutating it.
  aws eks update-kubeconfig --region "$region" --name "$cluster" --alias "$cluster" >/dev/null || return 1
  ctx="$cluster"
  kubectl config use-context "$ctx" >/dev/null || return 1

  local cluster_entry
  cluster_entry=$(kubectl config view \
    -o jsonpath="{.contexts[?(@.name==\"$ctx\")].context.cluster}" 2>/dev/null)
  if [[ -z "$cluster_entry" ]]; then
    echo "eks-ssm-forward: could not resolve cluster entry for context $ctx" >&2
    return 1
  fi

  kubectl config set-cluster "$cluster_entry" \
    --server="https://127.0.0.1:${local_port}" \
    --insecure-skip-tls-verify=true >/dev/null || return 1
  # Strip CA data so insecure-skip-tls-verify actually takes effect.
  kubectl config unset "clusters.${cluster_entry}.certificate-authority-data" >/dev/null 2>&1 || true
  kubectl config unset "clusters.${cluster_entry}.certificate-authority" >/dev/null 2>&1 || true
  echo "eks-ssm-forward: kubeconfig context '$ctx' -> https://127.0.0.1:${local_port} (insecure-skip-tls-verify)"

  # 3. Pick EC2 instance (bastion) and open the port-forward.
  instance=$(_aws_pick_ec2 "$region") || return 1
  [[ -z "$instance" ]] && { echo "eks-ssm-forward: no instance selected" >&2; return 1; }
  echo "eks-ssm-forward: starting SSM port-forward via $instance (localhost:${local_port} -> $endpoint_host:443)"

  # MSYS converts unknown leading slashes in args; disable for SSM JSON-ish params.
  MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' \
  aws ssm start-session \
    --region "$region" \
    --target "$instance" \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters "host=${endpoint_host},portNumber=443,localPortNumber=${local_port}"
}

# ec2-ssm
#   Pick a running EC2 instance (fzf) and open an interactive SSM shell.
#   Useful when you just want a shell on a bastion/host without port-forwarding.
ec2-ssm() {
  local region instance
  region=$(_aws_region ec2-ssm) || return 1

  instance=$(_aws_pick_ec2 "$region") || return 1
  [[ -z "$instance" ]] && { echo "ec2-ssm: no instance selected" >&2; return 1; }
  echo "ec2-ssm: starting interactive SSM session on $instance"

  aws ssm start-session --region "$region" --target "$instance"
}

# ec2-ssm-forward <host> <remote-port> [local-port]
#   Pick a running EC2 instance (fzf) and port-forward an arbitrary
#   destination <host>:<remote-port> through it via SSM, exposed locally on
#   127.0.0.1:<local-port>. <local-port> defaults to <remote-port>.
ec2-ssm-forward() {
  local region instance host remote_port local_port
  host="$1"
  remote_port="$2"
  local_port="${3:-$remote_port}"

  if [[ -z "$host" || -z "$remote_port" ]]; then
    echo "usage: ec2-ssm-forward <host> <remote-port> [local-port]" >&2
    return 1
  fi
  for p in "$remote_port" "$local_port"; do
    if ! [[ "$p" =~ ^[0-9]+$ ]] || (( p < 1 || p > 65535 )); then
      echo "ec2-ssm-forward: invalid port '$p' (1-65535)" >&2
      return 1
    fi
  done

  region=$(_aws_region ec2-ssm-forward) || return 1

  instance=$(_aws_pick_ec2 "$region") || return 1
  [[ -z "$instance" ]] && { echo "ec2-ssm-forward: no instance selected" >&2; return 1; }
  echo "ec2-ssm-forward: starting SSM port-forward via $instance (localhost:${local_port} -> ${host}:${remote_port})"

  MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' \
  aws ssm start-session \
    --region "$region" \
    --target "$instance" \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters "host=${host},portNumber=${remote_port},localPortNumber=${local_port}"
}
