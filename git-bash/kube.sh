#!/usr/bin/env bash

# kubectl aliases + bash completion.

command -v kubectl &>/dev/null || return 0

# Bash completion
source <(kubectl completion bash)

# kubecolor: optional drop-in color wrapper
if command -v kubecolor &>/dev/null; then
  alias k='kubecolor'
  alias kubectl='kubecolor'
  # Make completion also work for the wrapped commands
  complete -o default -F __start_kubectl kubecolor
  complete -o default -F __start_kubectl k
fi

# +--------------+
# | fzf helpers  |
# +--------------+

# Internal: fzf-select one (or many) resources, return name(s) on stdout.
# Args: <resource_type> [extra_kubectl_opts] [multi] [operation_label]
_k8s_select_resource() {
  local resource_type="$1"
  local options="$2"
  local multi="$3"
  local op="${4:-select}"
  op="$(tr '[:lower:]' '[:upper:]' <<< "${op:0:1}")${op:1}"

  [[ -z "$resource_type" ]] && { echo "select: resource type required" >&2; return 1; }

  local cols="NAME:.metadata.name,STATUS:.status.phase"
  case "$resource_type" in
    pod*)        cols="NAME:.metadata.name,PHASE:.status.phase,READY:.status.containerStatuses[*].ready" ;;
    deployment*) cols="NAME:.metadata.name,READY:.status.readyReplicas,REPLICAS:.status.replicas" ;;
  esac

  local info
  info=$(kubectl get "$resource_type" $options --no-headers -o custom-columns="$cols" 2>/dev/null) \
    || { echo "select: failed to list $resource_type" >&2; return 1; }
  [[ -z "$info" ]] && { echo "select: no $resource_type found" >&2; return 1; }

  local fzf_args=(--prompt="$op $resource_type: ")
  [[ "$multi" == "multi" ]] && fzf_args+=(--multi)

  echo "$info" | column -t | fzf "${fzf_args[@]}" | awk '{print $1}'
}

# Switch kubectl context
kctx() {
  local ctx
  ctx=$(kubectl config get-contexts -o name 2>/dev/null | fzf --prompt='Context: ') || return 1
  [[ -n "$ctx" ]] && kubectl config use-context "$ctx"
}

# Switch namespace in the current context
kns() {
  local ns
  ns=$(_k8s_select_resource namespaces "" "" "select") || return 1
  [[ -z "$ns" ]] && return 1
  kubectl config set-context --current --namespace="$ns" && echo "Switched to namespace: $ns"
}

# Exec into a pod (fzf), optional container picker, prefers bash then sh
kexec() {
  local pod
  pod=$(_k8s_select_resource pods "" "" "exec") || return 1
  [[ -z "$pod" ]] && return 1

  local containers
  containers=$(kubectl get pod "$pod" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)
  local container_flag=()
  if [[ $(echo "$containers" | wc -w) -gt 1 ]]; then
    local c
    c=$(echo "$containers" | tr ' ' '\n' | fzf --prompt='Container: ') || return 1
    [[ -z "$c" ]] && return 1
    container_flag=(-c "$c")
  fi

  if kubectl exec "$pod" "${container_flag[@]}" -- /bin/bash -c exit &>/dev/null; then
    kubectl exec -it "$pod" "${container_flag[@]}" -- /bin/bash
  else
    kubectl exec -it "$pod" "${container_flag[@]}" -- /bin/sh
  fi
}

# Port-forward a pod (fzf pod + fzf containerPort)
kport() {
  local pod
  pod=$(_k8s_select_resource pods "" "" "port-forward") || return 1
  [[ -z "$pod" ]] && return 1

  local ports port
  ports=$(kubectl get pod "$pod" -o jsonpath='{.spec.containers[*].ports[*].containerPort}' 2>/dev/null)
  if [[ -n "$ports" ]]; then
    port=$(echo "$ports" | tr ' ' '\n' | sort -u | fzf --prompt='Port: ') || return 1
  else
    read -r -p "No exposed ports declared. Enter port: " port
  fi
  [[ -z "$port" ]] && return 1
  echo "port-forward $pod  localhost:$port -> $port"
  kubectl port-forward "$pod" "$port:$port"
}

# Port-forward a service (fzf svc + fzf port)
ksvcport() {
  local svc
  svc=$(_k8s_select_resource services "" "" "port-forward") || return 1
  [[ -z "$svc" ]] && return 1

  local ports port
  ports=$(kubectl get service "$svc" -o jsonpath='{.spec.ports[*].port}' 2>/dev/null)
  if [[ $(echo "$ports" | wc -w) -gt 1 ]]; then
    port=$(echo "$ports" | tr ' ' '\n' | sort -u | fzf --prompt='Service port: ') || return 1
  elif [[ -n "$ports" ]]; then
    port="$ports"
  else
    read -r -p "No ports on service. Enter port: " port
  fi
  [[ -z "$port" ]] && return 1
  echo "port-forward service/$svc  localhost:$port -> $port"
  kubectl port-forward "service/$svc" "$port:$port"
}

# Logs from an fzf-picked pod (and container, when there are multiple).
# Flags: -f/--follow, -p/--previous, --tail=N, --since=DUR
klogs() {
  local follow=false previous=false tail_lines="" since=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--follow)   follow=true; shift ;;
      -p|--previous) previous=true; shift ;;
      --tail)        tail_lines="$2"; shift 2 ;;
      --tail=*)      tail_lines="${1#*=}"; shift ;;
      --since)       since="$2"; shift 2 ;;
      --since=*)     since="${1#*=}"; shift ;;
      -h|--help)
        echo "klogs [-f] [-p] [--tail=N] [--since=DUR]" >&2; return 0 ;;
      *) echo "klogs: unknown option $1" >&2; return 1 ;;
    esac
  done

  local pod
  pod=$(_k8s_select_resource pods "" "" "log") || return 1
  [[ -z "$pod" ]] && return 1

  # Include initContainers so you can read logs from failed init steps.
  local containers
  containers=$(kubectl get pod "$pod" \
    -o jsonpath='{.spec.initContainers[*].name} {.spec.containers[*].name}' 2>/dev/null)
  local container_flag=()
  if [[ $(echo "$containers" | wc -w) -gt 1 ]]; then
    local c
    c=$(echo "$containers" | tr ' ' '\n' | fzf --prompt='Container: ') || return 1
    [[ -z "$c" ]] && return 1
    container_flag=(-c "$c")
  fi

  local args=(logs "$pod" "${container_flag[@]}")
  [[ "$previous" == true ]] && args+=(-p)
  [[ "$follow"   == true ]] && args+=(-f)
  [[ -n "$tail_lines" ]] && args+=(--tail="$tail_lines")
  [[ -n "$since"      ]] && args+=(--since="$since")

  echo "kubectl ${args[*]}" >&2
  kubectl "${args[@]}"
}

alias krestarts='kubectl get pods --no-headers --sort-by='\''.status.containerStatuses[0].restartCount'\'''

# +---------+
# | kubectl |
# +---------+

alias kaf='kubectl apply -f'
alias keti='kubectl exec -ti'

alias kd='kubectl delete'
alias kdf='kubectl delete -f'

alias kg='kubectl get'
alias kgy='kubectl get -o yaml'
alias kgj='kubectl get -o json'
alias kgw='kubectl get -o wide'

# Pods
alias kgp='kubectl get pod'
alias kgpw='kubectl get pod -o wide'
alias kgpj='kubectl get pod -o json'
alias kgpy='kubectl get pod -o yaml'
alias kdp='kubectl delete pods'

# Jobs
alias kgjob='kubectl get jobs'
alias kgjobw='kubectl get jobs -o wide'
alias kgjobj='kubectl get jobs -o json'
alias kgjoby='kubectl get jobs -o yaml'
alias kej='kubectl edit jobs'
alias kdj='kubectl delete jobs'

# Pods by label / IPs
alias kgpl='kubectl get pod -l'
alias kgplw='kubectl get pod -o wide -l'
alias kgpip='kubectl get pod -A --no-headers -o custom-columns=":metadata.namespace,:metadata.name,:status.podIP" | sort -k3'

# Events
alias kge='kubectl get events --sort-by=.lastTimestamp'
alias kgecsv="kubectl get events --sort-by=.lastTimestamp -o json | jq -r '.items[] | [.firstTimestamp, .lastTimestamp, .reason, .message] | @csv'"
alias kgetsv="kubectl get events --sort-by=.lastTimestamp -o json | jq -r '.items[] | [.firstTimestamp, .lastTimestamp, .reason, .message] | @tsv'"

# Endpoints
alias kgep='kubectl get ep'
alias kgepw='kubectl get ep -o wide'
alias kgepj='kubectl get ep -o json'
alias kgepy='kubectl get ep -o yaml'

# Services
alias kgsvc='kubectl get svc'
alias kgsvcw='kubectl get svc -o wide'
alias kgsvcj='kubectl get svc -o json'
alias kgsvcy='kubectl get svc -o yaml'
alias kesvc='kubectl edit svc'
alias kdsvc='kubectl delete svc'

# Ingress
alias kgi='kubectl get ingress'
alias kgiw='kubectl get ingress -o wide'
alias kgij='kubectl get ingress -o json'
alias kgiy='kubectl get ingress -o yaml'
alias kei='kubectl edit ingress'
alias kdi='kubectl delete ingress'

# Namespaces
alias kgns='kubectl get namespaces'
alias kgnsj='kubectl get namespaces -o json'
alias kgnsy='kubectl get namespaces -o yaml'
alias kgnsw='kubectl get namespaces -o wide'
alias kens='kubectl edit namespace'
alias kdns='kubectl delete namespace'

# ConfigMaps
alias kgcm='kubectl get configmaps'
alias kgcmw='kubectl get configmaps -o wide'
alias kgcmj='kubectl get configmaps -o json'
alias kgcmy='kubectl get configmaps -o yaml'
alias kecm='kubectl edit configmap'
alias kdcm='kubectl delete configmap'

# Secrets
alias kgsec='kubectl get secret'
alias kgsecw='kubectl get secret -o wide'
alias kgsecj='kubectl get secret -o json'
alias kgsecy='kubectl get secret -o yaml'
alias kesec='kubectl edit secret'
alias kdsec='kubectl delete secret'

# Deployments
alias kgd='kubectl get deployment'
alias kgdw='kubectl get deployment -o wide'
alias kgdj='kubectl get deployment -o json'
alias kgdy='kubectl get deployment -o yaml'
alias ked='kubectl edit deployment'
alias kdd='kubectl delete deployment'
alias ksd='kubectl scale deployment'
alias krsd='kubectl rollout status deployment'
alias krrd='kubectl rollout restart deployment'

# Rollouts
alias kgrs='kubectl get rs'
alias krh='kubectl rollout history'
alias kru='kubectl rollout undo'

# Port-forward
alias kpf='kubectl port-forward'

# All
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias klp='kubectl logs -p'

# File copy
alias kcp='kubectl cp --retries=5'

# Nodes
alias kgno='kubectl get nodes'
alias kgnow='kubectl get nodes -o wide'
alias kgnoj='kubectl get nodes -o json'
alias kgnoy='kubectl get nodes -o yaml'

alias kgall='kubectl get all'
