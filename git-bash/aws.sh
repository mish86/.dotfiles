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

# Print a random free local port.
_aws_free_port() {
  local port i
  for i in $(seq 1 50); do
    port=$(( 20000 + RANDOM % 40000 ))
    (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null || { printf '%s\n' "$port"; return 0; }
  done
  echo "_aws_free_port: no free local port found" >&2
  return 1
}

# Print the InstanceId of a running instance with the exact Name tag.
_aws_ec2_by_name() {
  local ids
  ids=$(aws ec2 describe-instances --region "$1" \
    --filters "Name=tag:Name,Values=$2" 'Name=instance-state-name,Values=running' \
    --query 'Reservations[].Instances[].InstanceId' --output text)
  [[ -z "$ids" || "$ids" == "None" ]] && return 1
  printf '%s\n' "$ids" | tr '\t' '\n' | head -n1
}

# eks-ssm-forward <env>
#   Cluster = EKS cluster named exactly <env>; bastion = running EC2 instance
#   tagged Name=<env>-bastion-linux; local port = random free port.
#   Kubeconfig context '<env>' is created/patched, but the current context is
#   left as-is - use `kubectl --context <env> ...`.
eks-ssm-forward() {
  local env="$1" region cluster endpoint endpoint_host instance local_port
  local prev_ctx cluster_entry cmd

  [[ -z "$env" ]] && { echo "usage: eks-ssm-forward <env>" >&2; return 1; }

  region=$(_aws_region eks-ssm-forward) || return 1
  for cmd in kubectl jq; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "eks-ssm-forward: missing required command: $cmd" >&2
      return 1
    fi
  done

  cluster=$(aws eks list-clusters --region "$region" \
    --query "clusters[?@=='${env}'] | [0]" --output text)
  if [[ -z "$cluster" || "$cluster" == "None" ]]; then
    echo "eks-ssm-forward: no EKS cluster named '$env' in $region" >&2
    return 1
  fi

  endpoint=$(aws eks describe-cluster --region "$region" --name "$cluster" \
    --query 'cluster.endpoint' --output text)
  if [[ -z "$endpoint" || "$endpoint" == "None" ]]; then
    echo "eks-ssm-forward: could not resolve endpoint for $cluster" >&2
    return 1
  fi
  endpoint_host="${endpoint#https://}"
  endpoint_host="${endpoint_host%%/*}"
  endpoint_host="${endpoint_host%%:*}"

  instance=$(_aws_ec2_by_name "$region" "${env}-bastion-linux") || {
    echo "eks-ssm-forward: no running instance tagged Name=${env}-bastion-linux" >&2
    return 1
  }

  local_port=$(_aws_free_port) || return 1

  prev_ctx=$(kubectl config current-context 2>/dev/null)
  aws eks update-kubeconfig --region "$region" --name "$cluster" --alias "$env" >/dev/null || return 1
  [[ -n "$prev_ctx" ]] && kubectl config use-context "$prev_ctx" >/dev/null 2>&1

  cluster_entry=$(kubectl config view \
    -o jsonpath="{.contexts[?(@.name==\"$env\")].context.cluster}" 2>/dev/null)
  if [[ -z "$cluster_entry" ]]; then
    echo "eks-ssm-forward: could not resolve cluster entry for context $env" >&2
    return 1
  fi

  kubectl config set-cluster "$cluster_entry" \
    --server="https://127.0.0.1:${local_port}" \
    --insecure-skip-tls-verify=true >/dev/null || return 1
  # Strip CA data so insecure-skip-tls-verify actually takes effect.
  kubectl config unset "clusters.${cluster_entry}.certificate-authority-data" >/dev/null 2>&1 || true
  kubectl config unset "clusters.${cluster_entry}.certificate-authority" >/dev/null 2>&1 || true

  echo "eks-ssm-forward: context '$env' -> https://127.0.0.1:${local_port} (current context kept: ${prev_ctx:-none})"
  echo "eks-ssm-forward: use it with  kubectl --context $env get ns"
  echo "eks-ssm-forward: tunneling via $instance (localhost:${local_port} -> ${endpoint_host}:443)"

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
