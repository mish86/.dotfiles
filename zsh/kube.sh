#!/bin/bash

# NOTE: dependency on completion.sh

# https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/
[[ kubectl ]] && source <(kubectl completion zsh)

# NOTE: dependency on fzf.sh

# ftmux - help you choose tmux sessions
ftmux() {
  if [[ ! -n $TMUX ]]; then
    # get the IDs
    ID="$(tmux list-sessions 2>/dev/null)"
    if [[ -z "$ID" ]]; then
      tmux new-session
      return 0
    fi
    create_new_session="Create New Session"
    ID="$ID\n${create_new_session}:"
    ID="$(echo $ID | fzf | cut -d: -f1)"
    if [[ "$ID" = "${create_new_session}" ]]; then
      tmux new-session
    elif [[ -n "$ID" ]]; then
      printf '\033]777;tabbedx;set_tab_name;%s\007' "$ID"
      tmux attach-session -t "$ID"
    else
      : # Start terminal normally
    fi
  fi
}

ctx() {
  local context="$(kubectl config get-contexts -o name | fzf)"
  if [[ -n "$context" ]]; then
    kubectl config use-context "$context"
  else
    :
  fi
}
