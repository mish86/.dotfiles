#!/usr/bin/env bash

# AWS helpers (Git Bash on Windows).
# Requires: aws CLI, fzf, kubectl, jq, AWS Session Manager plugin.

command -v aws &>/dev/null || return 0
command -v fzf &>/dev/null || return 0

# eks-ssm-forward
#   1. Pick an EKS cluster (fzf) and remember its API endpoint.
#   2. Refresh kubeconfig for it, then rewrite the cluster entry to
#      point at https://127.0.0.1 with insecure-skip-tls-verify=true.
#   3. Pick a running EC2 bastion (fzf) and start an SSM port-forward
#      session that maps localhost:443 -> <cluster endpoint>:443.
eks-ssm-forward() {
  local region cluster endpoint endpoint_host instance ctx

  region="${AWS_REGION:-${AWS_DEFAULT_REGION:-$(aws configure get region 2>/dev/null)}}"
  if [[ -z "$region" ]]; then
    echo "eks-ssm-forward: AWS region not set (export AWS_REGION or aws configure)" >&2
    return 1
  fi

  for cmd in kubectl jq; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "eks-ssm-forward: missing required command: $cmd" >&2
      return 1
    fi
  done
  if ! aws ssm help 2>/dev/null | grep -q start-session; then
    : # aws ssm is built-in; the session-manager-plugin is checked at session time
  fi

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
    --server="https://127.0.0.1" \
    --insecure-skip-tls-verify=true >/dev/null || return 1
  # Strip CA data so insecure-skip-tls-verify actually takes effect.
  kubectl config unset "clusters.${cluster_entry}.certificate-authority-data" >/dev/null 2>&1 || true
  kubectl config unset "clusters.${cluster_entry}.certificate-authority" >/dev/null 2>&1 || true
  echo "eks-ssm-forward: kubeconfig context '$ctx' -> https://127.0.0.1 (insecure-skip-tls-verify)"

  # 3. Pick EC2 instance (bastion). Show id, name tag, state, private IP.
  instance=$(aws ec2 describe-instances --region "$region" \
      --filters 'Name=instance-state-name,Values=running' \
      --query 'Reservations[].Instances[].[InstanceId, (Tags[?Key==`Name`].Value | [0]) || `-`, PrivateIpAddress, InstanceType]' \
      --output text \
    | column -t \
    | fzf --prompt 'Bastion> ' --no-multi --exit-0 --select-1 \
    | awk '{print $1}') || return 1
  [[ -z "$instance" ]] && { echo "eks-ssm-forward: no instance selected" >&2; return 1; }
  echo "eks-ssm-forward: starting SSM port-forward via $instance (localhost:443 -> $endpoint_host:443)"

  # MSYS converts unknown leading slashes in args; disable for SSM JSON-ish params.
  MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' \
  aws ssm start-session \
    --region "$region" \
    --target "$instance" \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters "host=${endpoint_host},portNumber=443,localPortNumber=443"
}
