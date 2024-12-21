#!/bin/bash

# NOTE: dependency on completion.sh

# https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#enable-shell-autocompletion
source <(kubectl completion zsh)

# NOTE: dependency on fzf.sh

ctx() {
  local context="$(kubectl config get-contexts -o name | fzf)"
  if [[ -n "$context" ]]; then
    kubectl config use-context "$context"
  else
    :
  fi
}
