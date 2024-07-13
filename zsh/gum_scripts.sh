#!/bin/bash

function gtmux {
  if [ $1 ]; then
    tmuxifier load-session "$1" -CC
    if [ "$?" = 0 ]; then
      return 0;
    fi
  fi

  # get the IDs
  ID="`tmux list-sessions 2>/dev/null`"
  if [[ -z "$ID" ]]; then
    tmux new-session
    return 0
  fi

  create_new_session="Create New Session"
  ID="$ID\n${create_new_session}"
  SESSION="`echo $ID | gum filter --value="${1}" --placeholder 'Pick session...' | cut -d: -f1`"
  if [ -z "$SESSION" ]; then
    return 1
  fi

  if [[ "$SESSION" = "${create_new_session}" ]]; then
    tmux new-session
  elif [[ -n "$SESSION" ]]; then
    ([ "$TMUX" ] && tmux switch-client -t $SESSION) || tmux new-session -A -t $SESSION
  else
    :  # Start terminal normally
  fi
}

