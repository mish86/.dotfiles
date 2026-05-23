#!/usr/bin/env bash

# Bash completion. Git for Windows ships bash-completion 2.x.
# Common locations on Git Bash:
#   /mingw64/share/bash-completion/bash_completion
#   /usr/share/bash-completion/bash_completion

if ! shopt -oq posix; then
  for f in \
    /mingw64/share/bash-completion/bash_completion \
    /usr/share/bash-completion/bash_completion \
    /etc/bash_completion ; do
    if [[ -r "$f" ]]; then
      # shellcheck disable=SC1090
      source "$f"
      break
    fi
  done
fi

# Per-tool completions (kubectl, lazygit, fzf) are sourced from their own files.
