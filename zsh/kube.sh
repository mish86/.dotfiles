#!/bin/bash

# Kubernetes utilities with fzf integration
# Dependencies: kubectl, fzf, completion.sh

# Check for required dependencies
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH" >&2
    return 1
fi

if ! command -v fzf &> /dev/null; then
    echo "Error: fzf is not installed or not in PATH" >&2
    return 1
fi

# https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#enable-shell-autocompletion
source <(kubectl completion zsh)

# Kubecolor configuration
# https://github.com/vkhitrin/kubecolor-catppuccin
# export KUBECOLOR_CONFIG="$HOME/.config/catppuccin/kubecolor-catppuccin/catppuccin-macchiato.yaml"
export KUBECOLOR_CONFIG="$HOME/.config/catppuccin/kubecolor-catppuccin/catppuccin-frappe.yaml"

# Optional: Create aliases for kubecolor if available
if command -v kubecolor &> /dev/null; then
    alias k='kubecolor'
    alias kubectl='kubecolor'
    compdef kubecolor=kubectl
fi

# Helper function to select a resource with fzf
# Usage: _k8s_select_resource <resource_type> <prefix_pattern> <kubectl_options> [multi] [operation]
_k8s_select_resource() {
    local resource_type="$1"
    local prefix_pattern="$2"
    local options="$3"
    local multi_select="$4"
    local operation="${5:-select}"
    # upper case the first letter of operation
    operation="$(tr '[:lower:]' '[:upper:]' <<< ${operation:0:1})${operation:1}"

    if [[ -z "$resource_type" ]]; then
        echo "Error: resource type is required" >&2
        return 1
    fi
    

    # Get resource name and status columns for fzf preview
    local resource_info
    local custom_columns="NAME:.metadata.name,STATUS:.status.phase"
    if [[ "$resource_type" == pod* ]]; then
        custom_columns="NAME:.metadata.name,PHASE:.status.phase,READY:.status.containerStatuses[*].ready"
    elif [[ "$resource_type" == deployment* ]]; then
        custom_columns="NAME:.metadata.name,READY:.status.readyReplicas,REPLICAS:.status.replicas"
    fi
    if ! resource_info=$(kubectl get "$resource_type" $options --no-headers -o custom-columns="$custom_columns" 2>/dev/null); then
        echo "Error: Failed to get $resource_type info" >&2
        return 1
    fi

    if [[ -z "$resource_info" ]]; then
        echo "No $resource_type found in current namespace" >&2
        return 1
    fi

    # Build fzf arguments based on multi-select option
    local fzf_args=()
    local prompt_text="$operation $resource_type: "

    if [[ "$multi_select" == "multi" ]]; then
        fzf_args+=(--multi)
        prompt_text="$operation $resource_type (TAB for multiple): "
    fi

    fzf_args+=(--prompt="$prompt_text")

    # If kubectl options contain a label selector, preselect all resources
    local preselect_all=false
    if [[ "$options" =~ -l[[:space:]] ]] || [[ "$options" =~ --selector ]]; then
        preselect_all=true
        if [[ "$multi_select" == "multi" ]]; then
            fzf_args+=(--select-1)
            prompt_text="All matching $resource_type selected (TAB to modify): "
            fzf_args[${#fzf_args[@]}-1]="--prompt=$prompt_text"
        fi
    fi

    # Show name and status in fzf, but return only the name
    local selected
    if [[ "$preselect_all" == true && "$multi_select" == "multi" ]]; then
        selected=$(echo "$resource_info" | fzf "${fzf_args[@]}" --bind="start:select-all" | awk '{print $1}')
    else
        selected=$(echo "$resource_info" | fzf "${fzf_args[@]}" | awk '{print $1}')
    fi

    echo "$selected"
}

# Switch kubectl context
kctx() {
    local context_list
    if ! context_list=$(kubectl config get-contexts -o name 2>/dev/null); then
        echo "Error: Failed to get context list" >&2
        return 1
    fi
    
    if [[ -z "$context_list" ]]; then
        echo "No contexts found in kubeconfig" >&2
        return 1
    fi
    
    local context
    context=$(echo "$context_list" | fzf --prompt="Select context: ")
    
    if [[ -n "$context" ]]; then
        kubectl config use-context "$context"
    fi
}

# Switch namespace
kns() {
    local namespace
    if ! namespace=$(_k8s_select_resource "namespaces" "namespace/" "" "" "select"); then
        return 1
    fi
    
    if [[ -n "$namespace" ]]; then
        kubectl config set-context --current --namespace="$namespace"
        echo "Switched to namespace: $namespace"
    fi
}

# Generic function to get any resource type
_koperation_resource() {
    local kubectl_cmd=()

    # mandatory
    local operation="${1:-get}"
    kubectl_cmd+=("$operation")
    shift

    # mandatory
    local output_format="$1"
    if [[ -n "$output_format" ]]; then
        kubectl_cmd+=("-o" "$output_format")
        # shift if output_format is provided
    fi
    shift
    
    # optional
    local resource_type="$1"
    # skip if resource_type starts with '-'
    if [[ "$resource_type" == -* ]]; then
        resource_type=""
    elif [[ -n "$resource_type" ]]; then
        # shift if resource_type is provided
        shift
    fi

    if [[ "$resource_type" == "all" ]]; then
        kubectl_cmd+=("$resource_type")

        echo "Running command: kubectl ${kubectl_cmd[@]} $@"
        kubectl "${kubectl_cmd[@]}" "$@"
        return "$?"
    fi

    # optional
    local resource_name="$1"
    # skip if resource_name starts with '-'
    if [[ "$resource_name" == -* ]]; then
        resource_name=""
    elif [[ -n "$resource_name" ]]; then
        # shift if resource_name is provided
        shift
    fi

    if [[ "$resource_type" == */* ]]; then
        local parts=$resource_type
        resource_type=$(dirname "$parts")
        resource_name=$(basename "$parts")
    fi

    # optional label selector
    local label_selector=""

    # echo "resource_type: $resource_type"
    # echo "resource_name: $resource_name"
    # echo "Remaining arguments: $@"

    # used in _k8s_select_resource
    local kubectl_options=()

    # Parse optional flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            -l|--selector)
                if [[ -n "$2" ]]; then
                    label_selector="$2"
                    shift 2
                else
                    echo "Error: -l/--selector requires a label selector (e.g., app=myapp)" >&2
                    return 1
                fi
                ;;
            --selector=*)
                label_selector="${1#*=}"
                if [[ -z "$label_selector" ]]; then
                    echo "Error: --selector requires a label selector (e.g., app=myapp)" >&2
                    return 1
                fi
                shift
                ;;
            -A|--all-namespaces)
                kubectl_cmd+=("--all-namespaces")
                kubectl_options+=("--all-namespaces")
                shift
                ;;
            --show-labels)
                kubectl_cmd+=("--show-labels")
                kubectl_options+=("--show-labels")
                shift
                ;;
            *)
                echo "Error: Unknown option $1" >&2
                echo "Usage: $0 [-l|--selector <label_selector>]" >&2
                return 1
                ;;
        esac
    done
    
    # If no resource type provided, let user select with fzf
    if [[ -z "$resource_type" ]]; then
        # Get all available resource types from the cluster
        local resource_types
        if ! resource_types=$(kubectl api-resources --output=name 2>/dev/null | sort); then
            echo "Error: Failed to get available resource types" >&2
            return 1
        fi
        
        if [[ -z "$resource_types" ]]; then
            echo "No resource types found" >&2
            return 1
        fi
        
        resource_type=$(echo "$resource_types" | fzf --prompt="Select resource type: " --height=20)
        
        if [[ -z "$resource_type" ]]; then
            echo "No resource type selected"
            return 1
        fi
    fi
    kubectl_cmd+=("$resource_type")
    
    # if label_selector is provided use it
    # otherwise, if resource_name is not provided, let user select with fzf
    if [[ -n "$label_selector" ]]; then
        kubectl_cmd+=("-l" "$label_selector")
        echo "Running command: kubectl ${kubectl_cmd[@]} $@" >&2
        kubectl "${kubectl_cmd[@]}" "$@"
        return "$?"      
    elif [[ -z "$resource_name" && "$resource_type" != node* ]]; then
        local multi_select=""
        if [[ "$operation" != "edit" ]]; then
            multi_select="multi"
        fi
        if ! resource_name=$(_k8s_select_resource "$resource_type" "" "$kubectl_options" "$multi_select" "$operation"); then
            echo "No resource selected"
            return 1
        fi
    fi

    # If multiple resources selected (newline separated), run for each
    local resource_names=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && resource_names+=("$line")
    done <<< "$resource_name"
    for name in "${resource_names[@]}"; do
        local cmd=("${kubectl_cmd[@]}")
        cmd+=("$name")
        echo "Running command: kubectl ${cmd[@]} $@" >&2
        kubectl "${cmd[@]}" "$@"
    done
}

# Get any resource type in any format
kgety() {
    _koperation_resource "get" "yaml" "$@"
}

kgetj() {
    _koperation_resource "get" "json" "$@"
}

kgetw() {
    _koperation_resource "get" "wide" "$@"
}

kget() {
    _koperation_resource "get" "" "$@"
}

# Describe any resource type
kdesc() {
    _koperation_resource "describe" "" "$@"
}

# Get pod YAML
kpody() {
    _koperation_resource get yaml pods "$@"
}

# Get pod JSON
kpodj() {
    _koperation_resource get json pods "$@"
}

kpodw() {
    _koperation_resource get wide pods "$@"
}

kpod() {
    _koperation_resource get "" pods "$@"
}

# Get deployment YAML
kdeployy() {
    kgety deployments "$@"
}

# Get deployment JSON
kdeployj() {
    kgetj deployments "$@"
}

# Get configmap YAML
kcmy() {
    kgety configmaps "$@"
}

# Get configmap JSON
kcmj() {
    kgetj configmaps "$@"
}

# Get secret YAML
ksecy() {
    kgety secrets "$@"
}

# Get secret JSON
ksecj() {
    kgetj secrets "$@"
}

# Get secret data decoded (base64 decoded)
ksecd() {
    # Check if jq is available first
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required for decoding secrets but not found in PATH" >&2
        echo "Install jq or use 'ksecj' to get raw JSON data" >&2
        return 1
    fi
    
    # Use the generic JSON function and pipe to jq for decoding
    ksecj | jq '.data | map_values(@base64d)'
}

# Edit any resource type
kedit() {
    _koperation_resource "edit" "" "$@"
}

# Edit any resource type
kdel() {
    _koperation_resource "delete" "" "$@"
}


# Get logs from a pod (supports multi-selection with TAB)
klogs() {
    local save_to_file=false
    local follow=false
    local previous=false
    local tail_lines=""
    local since=""
    local since_time=""
    local label_selector=""
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--save)
                save_to_file=true
                follow=false
                shift
                ;;
            -f|--follow)
                follow=true
                shift
                ;;
            -p|--previous)
                previous=true
                shift
                ;;
            -l|--selector)
                if [[ -n "$2" ]]; then
                    label_selector="$2"
                    shift 2
                else
                    echo "Error: -l/--selector requires a label selector (e.g., app=myapp)" >&2
                    return 1
                fi
                ;;
            --selector=*)
                label_selector="${1#*=}"
                if [[ -z "$label_selector" ]]; then
                    echo "Error: --selector requires a label selector (e.g., app=myapp)" >&2
                    return 1
                fi
                shift
                ;;
            --tail)
                if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                    tail_lines="$2"
                    shift 2
                else
                    echo "Error: --tail requires a numeric argument" >&2
                    return 1
                fi
                ;;
            --tail=*)
                tail_lines="${1#*=}"
                if [[ ! "$tail_lines" =~ ^[0-9]+$ ]]; then
                    echo "Error: --tail requires a numeric argument" >&2
                    return 1
                fi
                shift
                ;;
            --since)
                if [[ -n "$2" ]]; then
                    since="$2"
                    shift 2
                else
                    echo "Error: --since requires an argument (e.g., 5m, 1h, 24h)" >&2
                    return 1
                fi
                ;;
            --since=*)
                since="${1#*=}"
                if [[ -z "$since" ]]; then
                    echo "Error: --since requires an argument (e.g., 5m, 1h, 24h)" >&2
                    return 1
                fi
                shift
                ;;
            --since-time)
                if [[ -n "$2" ]]; then
                    since_time="$2"
                    shift 2
                else
                    echo "Error: --since-time requires a timestamp (RFC3339 format)" >&2
                    return 1
                fi
                ;;
            --since-time=*)
                since_time="${1#*=}"
                if [[ -z "$since_time" ]]; then
                    echo "Error: --since-time requires a timestamp (RFC3339 format)" >&2
                    return 1
                fi
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Use multi-select only when saving to file
    local multi_mode=""
    if [[ "$save_to_file" == true ]]; then
        multi_mode="multi"
    fi
    
    # Build kubectl options for label selector
    local kubectl_options=""
    if [[ -n "$label_selector" ]]; then
        kubectl_options="-l $label_selector"
    fi
    
    local selected_pods
    if ! selected_pods=$(_k8s_select_resource "pods" "pod/" "$kubectl_options" "$multi_mode" "log"); then
        return 1
    fi
    
    # Convert selected pods to array (split by newlines)
    local pods_array=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && pods_array+=("$line")
    done <<< "$selected_pods"
    
    # Process each selected pod
    local pod_count=${#pods_array[@]}
    
    if [[ "$save_to_file" == true ]]; then
        # Multi-pod file saving mode
        local current_pod=1
        for pod in "${pods_array[@]}"; do
            echo "\n[${current_pod}/${pod_count}] Processing pod: $pod"
            
            # Get all containers (init + regular containers) and handle newlines properly
            local all_containers=()
            local init_containers_raw
            local containers_raw
            init_containers_raw=$(kubectl get pod "$pod" -o jsonpath='{.spec.initContainers[*].name}' 2>/dev/null)
            containers_raw=$(kubectl get pod "$pod" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)

            # Convert space-separated to newline-separated, then read into array
            if [[ -n "$init_containers_raw" ]]; then
                while IFS= read -r container; do
                    [[ -n "$container" ]] && all_containers+=("$container")
                done < <(echo "$init_containers_raw" | tr ' ' '\n')
            fi
            if [[ -n "$containers_raw" ]]; then
                while IFS= read -r container; do
                    [[ -n "$container" ]] && all_containers+=("$container")
                done < <(echo "$containers_raw" | tr ' ' '\n')
            fi

            # Save logs for each container automatically
            local container_count=${#all_containers[@]}
            for container in "${all_containers[@]}"; do
                local container_flag
                local filename
                if [[ ${#all_containers[@]} -gt 1 ]]; then
                    filename="${pod}-${container}"
                    filename="${pod}-${container}$( [[ "$previous" == true ]] && echo .prev ).log"
                    container_flag="-c $container"
                    echo "  Saving logs for container '$container' to: $filename"
                else
                    filename="${pod}$( [[ "$previous" == true ]] && echo .prev ).log"
                    echo "  Saving logs to: $filename"
                fi

                # Build kubectl logs command with optional tail, since, and since-time
                local kubectl_cmd="kubectl logs $pod $container_flag"
                if [[ "$previous" == true ]]; then
                    kubectl_cmd="$kubectl_cmd -p"
                fi
                if [[ -n "$tail_lines" ]]; then
                    kubectl_cmd="$kubectl_cmd --tail=$tail_lines"
                fi
                if [[ -n "$since" ]]; then
                    kubectl_cmd="$kubectl_cmd --since=$since"
                fi
                if [[ -n "$since_time" ]]; then
                    kubectl_cmd="$kubectl_cmd --since-time=$since_time"
                fi

                if eval "$kubectl_cmd" > "$filename" 2>/dev/null; then
                    echo "    ✓ Logs saved to: $filename"
                else
                    echo "    ✗ Failed to get logs for container '$container'"
                fi
            done
            
            ((current_pod++))
        done
    else
        # Single pod interactive mode (view or follow)
        local pod="${pods_array[1]}"
        
        # Show all containers (including init containers and those not started)
        local containers
        containers=$(kubectl get pod "$pod" -o jsonpath='{.spec.initContainers[*].name} {.spec.containers[*].name}' 2>/dev/null)
        local container_count=$(echo "$containers" | wc -w)

        local container_flag=""
        if [[ $container_count -gt 1 ]]; then
            local container
            container=$(echo "$containers" | tr ' ' '\n' | fzf --prompt="Select container (init and app): ")
            if [[ -n "$container" ]]; then
                container_flag="-c $container"
            else
                echo "No container selected"
                return 1
            fi
        fi

        # Build kubectl logs command with optional tail, since, and since-time
        local kubectl_cmd="kubectl logs $pod $container_flag"
        if [[ "$previous" == true ]]; then
            kubectl_cmd="$kubectl_cmd -p"
        fi
        if [[ -n "$tail_lines" ]]; then
            kubectl_cmd="$kubectl_cmd --tail=$tail_lines"
        fi
        if [[ -n "$since" ]]; then
            kubectl_cmd="$kubectl_cmd --since=$since"
        fi
        if [[ -n "$since_time" ]]; then
            kubectl_cmd="$kubectl_cmd --since-time=$since_time"
        fi

        if [[ "$follow" == true ]]; then
            kubectl_cmd="$kubectl_cmd -f"
        fi

        echo "Running command: $kubectl_cmd"
        eval "$kubectl_cmd"
    fi
}

# Execute command in pod
kexec() {
    local pod
    if ! pod=$(_k8s_select_resource "pods" "pod/" "" "" "execute"); then
        return 1
    fi
    
    if [[ -n "$pod" ]]; then
        # Check if pod has multiple containers
        local containers
        containers=$(kubectl get pod "$pod" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)
        local container_count=$(echo "$containers" | wc -w)
        
        if [[ $container_count -gt 1 ]]; then
            local container
            container=$(echo "$containers" | tr ' ' '\n' | fzf --prompt="Select container: ")
            if [[ -n "$container" ]]; then
                kubectl exec -it "$pod" -c "$container" -- /bin/sh
            fi
        else
            # Try to exec into bash, fallback to sh if bash is not available
            if kubectl exec "$pod" -- /bin/bash -c "exit" &>/dev/null; then
              kubectl exec -it "$pod" -- /bin/bash
            else
              kubectl exec -it "$pod" -- /bin/sh
            fi
        fi
    fi
}

# Port forward to a pod
kport() {
    local pod
    if ! pod=$(_k8s_select_resource "pods" "pod/" "" "" "port forward"); then
        return 1
    fi
    
    if [[ -n "$pod" ]]; then
        # Get pod ports
        local ports
        ports=$(kubectl get pod "$pod" -o jsonpath='{.spec.containers[*].ports[*].containerPort}' 2>/dev/null)
        
        if [[ -n "$ports" ]]; then
            local port
            port=$(echo "$ports" | tr ' ' '\n' | sort -u | fzf --prompt="Select port: ")
            if [[ -n "$port" ]]; then
                echo "Port forwarding $pod:$port to localhost:$port"
                kubectl port-forward "$pod" "$port:$port"
            fi
        else
            echo "No ports found for pod $pod"
            echo -n "Enter port to forward: "
            read port
            if [[ -n "$port" ]]; then
                echo "Port forwarding $pod:$port to localhost:$port"
                kubectl port-forward "$pod" "$port:$port"
            fi
        fi
    fi
}

# Port forward to a service
ksvcport() {
    local service
    if ! service=$(_k8s_select_resource "services" "service/" "" "port forward"); then
        return 1
    fi
    
    if [[ -n "$service" ]]; then
        # Get service ports
        local ports
        ports=$(kubectl get service "$service" -o jsonpath='{.spec.ports[*].port}' 2>/dev/null)
        
        if [[ -n "$ports" ]]; then
            # If there are multiple ports, let user select one
            local port_count=$(echo "$ports" | wc -w)
            if [[ $port_count -gt 1 ]]; then
                local port
                port=$(echo "$ports" | tr ' ' '\n' | sort -u | fzf --prompt="Select service port: ")
                if [[ -n "$port" ]]; then
                    echo "Port forwarding service/$service:$port to localhost:$port"
                    kubectl port-forward "service/$service" "$port:$port"
                fi
            else
                # Single port, use it directly
                echo "Port forwarding service/$service:$ports to localhost:$ports"
                kubectl port-forward "service/$service" "$ports:$ports"
            fi
        else
            echo "No ports found for service $service"
            echo -n "Enter port to forward: "
            read port
            if [[ -n "$port" ]]; then
                echo "Port forwarding service/$service:$port to localhost:$port"
                kubectl port-forward "service/$service" "$port:$port"
            fi
        fi
    fi
}

alias krestarts='kubectl get pods --no-headers --sort-by='\''.status.containerStatuses[0].restartCount'\'''

# +---------+
# | kubectl |
# +---------+

# Execute a kubectl command against all namespaces
# alias kca='f(){ kubectl "$@" --all-namespaces;  unset -f f; }; f'

# Apply a YML file
alias kaf='kubectl apply -f'

# Drop into an interactive terminal on a container
alias keti='kubectl exec -ti'

# Manage configuration quickly to switch contexts between local, dev ad staging.
# alias kcuc='kubectl config use-context'
# alias kcsc='kubectl config set-context'
# alias kcdc='kubectl config delete-context'
# alias kccc='kubectl config current-context'

# List all contexts
# alias kcgc='kubectl config get-contexts'

# General aliases
alias kd='kubectl delete'
alias kdf='kubectl delete -f'

alias kg='kubectl get'
alias kgy='kubectl get -o yaml'
alias kgj='kubectl get -o json'
alias kgw='kubectl get -o wide'

# Pod management.
alias kgp='kubectl get pod'
# alias kgpw='kgp --watch'
alias kgpw='kubectl get pod -o wide'
alias kgpj='kubectl get pod -o json'
alias kgpy='kubectl get pod -o yaml'
# alias kep='kubectl edit pods'
alias kdp='kubectl delete pods'

alias kgjob='kubectl get jobs'
alias kgjobw='kubectl get jobs -o wide'
alias kgjobj='kubectl get jobs -o json'
alias kgjoby='kubectl get jobs -o yaml'
alias kej='kubectl edit jobs'
alias kdj='kubectl delete jobs'

# get pod by label: kgpl "app=myapp" -n myns
alias kgpl='kubectl get pod -l'
alias kgplw='kubectl get pod -o wide -l'
# get pods with IPs, sorted by IP
# can be accomponied with | uniq -D to show duplicates
alias kgpip='kubectl get pod -A --no-headers -o custom-columns=":metadata.namespace,:metadata.name,:status.podIP" | sort -k3'

# Events
alias kge='kubectl get events --sort-by=.lastTimestamp'
alias kgecsv="kubectl get events --sort-by=.lastTimestamp -o json | jq -r '.items[] | [.firstTimestamp, .lastTimestamp, .reason, .message] | @csv'"
alias kgetsv="kubectl get events --sort-by=.lastTimestamp -o json | jq -r '.items[] | [.firstTimestamp, .lastTimestamp, .reason, .message] | @tsv'"

alias kgep='kubectl get ep'
alias kgepw='kubectl get ep -o wide'
alias kgepj='kubectl get ep -o json'
alias kgepy='kubectl get ep -o yaml'

# Service management.
alias kgsvc='kubectl get svc'
# alias kgsw='kgs --watch'
alias kgsvcw='kubectl get svc -o wide'
alias kgsvcj='kubectl get svc -o json'
alias kgsvcy='kubectl get svc -o yaml'
alias kesvc='kubectl edit svc'
alias kdsvc='kubectl delete svc'

# Ingress management
alias kgi='kubectl get ingress'
alias kgiw='kubectl get ingress -o wide'
alias kgij='kubectl get ingress -o json'
alias kgiy='kubectl get ingress -o yaml'
alias kei='kubectl edit ingress'
alias kdi='kubectl delete ingress'

# Namespace management
alias kgns='kubectl get namespaces'
alias kgnsj='kubectl get namespaces -o json'
alias kgnsy='kubectl get namespaces -o yaml'
alias kgnsw='kubectl get namespaces -o wide'
alias kens='kubectl edit namespace'
alias kdns='kubectl delete namespace'
# alias kcn='kubectl config set-context $(kubectl config current-context) --namespace'

# ConfigMap management
alias kgcm='kubectl get configmaps'
alias kgcmw='kubectl get configmaps -o wide'
alias kgcmj='kubectl get configmaps -o json'
alias kgcmy='kubectl get configmaps -o yaml'
alias kecm='kubectl edit configmap'
alias kdcm='kubectl delete configmap'

# Secret management
alias kgsec='kubectl get secret'
alias kgsecw='kubectl get secret -o wide'
alias kgsecj='kubectl get secret -o json'
alias kgsecy='kubectl get secret -o yaml'
alias kesec='kubectl edit secret'
alias kdsec='kubectl delete secret'

# Deployment management.
alias kgd='kubectl get deployment'
# alias kgdw='kgd --watch'
alias kgdw='kubectl get deployment -o wide'
alias kgdj='kubectl get deployment -o json'
alias kgdy='kubectl get deployment -o yaml'
alias ked='kubectl edit deployment'
alias kdd='kubectl delete deployment'
alias ksd='kubectl scale deployment'
alias krsd='kubectl rollout status deployment'
alias krrd='kubectl rollout restart deployment'
# kres(){
#     kubectl set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
# }

# Rollout management.
alias kgrs='kubectl get rs'
alias krh='kubectl rollout history'
alias kru='kubectl rollout undo'

# Port forwarding
alias kpf="kubectl port-forward"

# Tools for accessing all information
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias klp='kubectl logs -p'
alias klrg='f(){ kubectl get pods 2> /dev/null | rg "$@" | awk '\''{print $1}'\'' | xargs -I {} sh -c '\''kubectl logs {} > {}.log'\'';  unset -f f; }; f'
alias kll='f(){ kubectl get pods --no-headers -l "$@" 2> /dev/null | awk '\''{print $1}'\'' | xargs -I {} sh -c '\''kubectl logs {} > {}.log'\'';  unset -f f; }; f'

# File copy
alias kcp='kubectl cp --retries=5'

# Node Management
alias kgno='kubectl get nodes'
alias kgnow='kubectl get nodes -o wide'
alias kgnoj='kubectl get nodes -o json'
alias kgnoy='kubectl get nodes -o yaml'
# alias keno='kubectl edit node'
# alias kdno='kubectl describe node'
# alias kdelno='kubectl delete node'

# get resource in yaml or json format
alias kgy='kubectl get -o yaml'
alias kgj='kubectl get -o json'
alias kgw='kubectl get -o wide'
alias kgall='kubectl get all'
