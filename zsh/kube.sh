#!/usr/bin/env zsh

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

# Helper function to select a resource with fzf
# Usage: _k8s_select_resource <resource_type> <prefix_pattern> <kubectl_options> [multi]
_k8s_select_resource() {
    local resource_type="$1"
    local prefix_pattern="$2"
    local options="$3"
    local multi_select="$4"
    
    if [[ -z "$resource_type" ]]; then
        echo "Error: resource type is required" >&2
        return 1
    fi
    
    local resource_list
    if ! resource_list=$(kubectl get "$resource_type" $options -o name 2>/dev/null); then
        echo "Error: Failed to get $resource_type list" >&2
        return 1
    fi
    
    if [[ -z "$resource_list" ]]; then
        echo "No $resource_type found in current namespace" >&2
        return 1
    fi
    
    # Build fzf arguments based on multi-select option
    local fzf_args=()
    local prompt_text="Select $resource_type: "
    
    if [[ "$multi_select" == "multi" ]]; then
        fzf_args+=(--multi)
        prompt_text="Select $resource_type (TAB for multiple): "
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
    
    local selected
    if [[ -n "$prefix_pattern" ]]; then
        # Use provided prefix pattern
        if [[ "$preselect_all" == true && "$multi_select" == "multi" ]]; then
            # For label selectors with multi-select, select all by default
            selected=$(echo "$resource_list" | sed "s|^$prefix_pattern||" | fzf "${fzf_args[@]}" --bind="start:select-all")
        else
            selected=$(echo "$resource_list" | sed "s|^$prefix_pattern||" | fzf "${fzf_args[@]}")
        fi
    else
        # Auto-detect and remove prefix (everything before the first '/')
        if [[ "$preselect_all" == true && "$multi_select" == "multi" ]]; then
            # For label selectors with multi-select, select all by default
            selected=$(echo "$resource_list" | sed 's|^[^/]*/||' | fzf "${fzf_args[@]}" --bind="start:select-all")
        else
            selected=$(echo "$resource_list" | sed 's|^[^/]*/||' | fzf "${fzf_args[@]}")
        fi
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
    if ! namespace=$(_k8s_select_resource "namespaces" "namespace/" ""); then
        return 1
    fi
    
    if [[ -n "$namespace" ]]; then
        kubectl config set-context --current --namespace="$namespace"
        echo "Switched to namespace: $namespace"
    fi
}

# Get pod YAML
kpody() {
    kgety pods
}

# Get pod JSON
kpodj() {
    kgetj pods
}

# Helper function for listing pods with optional label selector and output format
_kpod_list() {
    local output_format="$1"
    shift
    local label_selector=""
    local function_name="${output_format:+kpodw}"
    function_name="${function_name:-kpod}"
    
    # Parse options
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
            *)
                echo "Error: Unknown option $1" >&2
                echo "Usage: $function_name [-l|--selector <label_selector>]" >&2
                return 1
                ;;
        esac
    done
    
    # Build kubectl command
    local kubectl_cmd="kubectl get pods"
    if [[ -n "$output_format" ]]; then
        kubectl_cmd="$kubectl_cmd -o $output_format"
    fi
    if [[ -n "$label_selector" ]]; then
        kubectl_cmd="$kubectl_cmd -l \"$label_selector\""
    fi
    
    eval "$kubectl_cmd"
}

# List pods
kpod() {
    _kpod_list "" "$@"
}

# List pods with wide output
kpodw() {
    _kpod_list "wide" "$@"
}

# Get deployment YAML
kdeployy() {
    kgety deployments
}

# Get deployment JSON
kdeployj() {
    kgetj deployments
}

# Get configmap YAML
kcmy() {
    kgety configmaps
}

# Get configmap JSON
kcmj() {
    kgetj configmaps
}

# Get secret YAML
ksecy() {
    kgety secrets
}

# Get secret JSON
ksecj() {
    kgetj secrets
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
    kgetj secrets | jq '.data | map_values(@base64d)'
}

# Get any resource type in YAML format (generic function)
kgety() {
    local resource_type="$1"
    
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
    
    local resource_name
    if ! resource_name=$(_k8s_select_resource "$resource_type" "" ""); then
        return 1
    fi
    
    if [[ -n "$resource_name" ]]; then
        kubectl get "$resource_type" "$resource_name" -o yaml
    fi
}

# Get any resource type in JSON format (generic function)
kgetj() {
    local resource_type="$1"
    
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
    
    local resource_name
    if ! resource_name=$(_k8s_select_resource "$resource_type" "" ""); then
        return 1
    fi
    
    if [[ -n "$resource_name" ]]; then
        kubectl get "$resource_type" "$resource_name" -o json
    fi
}

# Describe any resource type
kdesc() {
    local resource_type="$1"
    
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
    
    local resource_name
    if ! resource_name=$(_k8s_select_resource "$resource_type" "" ""); then
        return 1
    fi
    
    if [[ -n "$resource_name" ]]; then
        kubectl describe "$resource_type" "$resource_name"
    fi
}

# Edit any resource type
kedit() {
    local resource_type="$1"
    
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
    
    local resource_name
    if ! resource_name=$(_k8s_select_resource "$resource_type" "" ""); then
        return 1
    fi
    
    if [[ -n "$resource_name" ]]; then
        kubectl edit "$resource_type" "$resource_name"
    fi
}

# Get logs from a pod (supports multi-selection with TAB)
klogs() {
    local save_to_file=false
    local follow=false
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
    if ! selected_pods=$(_k8s_select_resource "pods" "pod/" "$kubectl_options" "$multi_mode"); then
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
            
            # Check if pod has multiple containers
            local containers
            containers=$(kubectl get pod "$pod" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)
            local container_count=$(echo "$containers" | wc -w)
            
            local container_flag=""
            local container_name=""
            if [[ $container_count -gt 1 ]]; then
                local container
                container=$(echo "$containers" | tr ' ' '\n' | fzf --prompt="Select container for pod $pod: ")
                if [[ -n "$container" ]]; then
                    container_flag="-c $container"
                    container_name="$container"
                else
                    echo "No container selected for pod $pod, skipping..."
                    ((current_pod++))
                    continue
                fi
            fi
            
            local filename="${pod}${container_name:+-$container_name}.log"
            echo "Saving logs to: $filename"
            
            # Build kubectl logs command with optional tail, since, and since-time
            local kubectl_cmd="kubectl logs $pod $container_flag"
            if [[ -n "$tail_lines" ]]; then
                kubectl_cmd="$kubectl_cmd --tail=$tail_lines"
            fi
            if [[ -n "$since" ]]; then
                kubectl_cmd="$kubectl_cmd --since=$since"
            fi
            if [[ -n "$since_time" ]]; then
                kubectl_cmd="$kubectl_cmd --since-time=$since_time"
            fi
            
            eval "$kubectl_cmd" > "$filename"
            echo "Logs saved to: $filename"
            
            ((current_pod++))
        done
    else
        # Single pod interactive mode (view or follow)
        local pod="${pods_array[1]}"
        
        # Check if pod has multiple containers
        local containers
        containers=$(kubectl get pod "$pod" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)
        local container_count=$(echo "$containers" | wc -w)
        
        local container_flag=""
        if [[ $container_count -gt 1 ]]; then
            local container
            container=$(echo "$containers" | tr ' ' '\n' | fzf --prompt="Select container: ")
            if [[ -n "$container" ]]; then
                container_flag="-c $container"
            else
                echo "No container selected"
                return 1
            fi
        fi
        
        # Build kubectl logs command with optional tail, since, and since-time
        local kubectl_cmd="kubectl logs $pod $container_flag"
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
            eval "$kubectl_cmd -f"
        else
            eval "$kubectl_cmd"
        fi
    fi
}

# Execute command in pod
kexec() {
    local pod
    if ! pod=$(_k8s_select_resource "pods" "pod/" ""); then
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
    if ! pod=$(_k8s_select_resource "pods" "pod/" ""); then
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
    if ! service=$(_k8s_select_resource "services" "service/" ""); then
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

# +---------+
# | kubectl |
# +---------+

# # use colorized kubectl output
# alias kubectl='kubecolor'
# # shortcut for kubectl
# alias k='kubectl'

# Execute a kubectl command against all namespaces
alias kca='f(){ kubectl "$@" --all-namespaces;  unset -f f; }; f'

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
alias krm='kubectl delete'
alias krmf='kubectl delete -f'

# Pod management.
alias kgp='kubectl get pod'
# alias kgpw='kgp --watch'
alias kgpw='kubectl get pod -o wide'
alias kgpj='kubectl get pod -o json'
alias kgpy='kubectl get pod -o yaml'
# alias kep='kubectl edit pods'
alias kdp='kubectl describe pods'
alias kdp='kubectl delete pods'

# get pod by label: kgpl "app=myapp" -n myns
alias kgpl='kubectl get pod -l'
alias kgplw='kubectl get pod -o wide -l'
# get pods with IPs, sorted by IP
# can be accomponied with | uniq -D to show duplicates
alias kgpip='kubectl get pod -A --no-headers -o custom-columns=":metadata.namespace,:metadata.name,:status.podIP" | sort -k3'

alias kge='kubectl get events --sort-by=.lastTimestamp'

# Service management.
alias kgs='kubectl get svc'
# alias kgsw='kgs --watch'
alias kgsw='kubectl get svc -o wide'
alias kgsj='kubectl get svc -o json'
alias kgsy='kubectl get svc -o yaml'
alias kes='kubectl edit svc'
alias kds='kubectl describe svc'
alias kds='kubectl delete svc'

# Ingress management
alias kgi='kubectl get ingress'
alias kgiw='kubectl get ingress -o wide'
alias kgij='kubectl get ingress -o json'
alias kgiy='kubectl get ingress -o yaml'
alias kei='kubectl edit ingress'
alias kdi='kubectl describe ingress'
alias kdi='kubectl delete ingress'

# Namespace management
alias kgns='kubectl get namespaces'
alias kens='kubectl edit namespace'
alias kdns='kubectl describe namespace'
alias kdns='kubectl delete namespace'
# alias kcn='kubectl config set-context $(kubectl config current-context) --namespace'

# ConfigMap management
alias kgcm='kubectl get configmaps'
alias kgcmw='kubectl get configmaps -o wide'
alias kgcmj='kubectl get configmaps -o json'
alias kgcmy='kubectl get configmaps -o yaml'
alias kecm='kubectl edit configmap'
alias kdcm='kubectl describe configmap'
alias kdcm='kubectl delete configmap'

# Secret management
alias kgsec='kubectl get secret'
alias kgsecw='kubectl get secret -o wide'
alias kgsecj='kubectl get secret -o json'
alias kgsecy='kubectl get secret -o yaml'
alias kesec='kubectl edit secret'
alias kdsec='kubectl describe secret'
alias kdsec='kubectl delete secret'

# Deployment management.
alias kgd='kubectl get deployment'
# alias kgdw='kgd --watch'
alias kgdw='kubectl get deployment -o wide'
alias kgdj='kubectl get deployment -o json'
alias kgdy='kubectl get deployment -o yaml'
alias ked='kubectl edit deployment'
alias kdd='kubectl describe deployment'
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
alias kcp='kubectl cp'

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


# Kubecolor configuration
# https://github.com/vkhitrin/kubecolor-catppuccin
export KUBECOLOR_CONFIG="$HOME/.config/catppuccin/kubecolor-catppuccin/catppuccin-latte.yaml"

# Optional: Create aliases for kubecolor if available
if command -v kubecolor &> /dev/null; then
    alias k='kubecolor'
    alias kubectl='kubecolor'
fi
