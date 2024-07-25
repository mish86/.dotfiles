#!/bin/bash

bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey '^[^?' backward-kill-word
bindkey '^[[3;3~' kill-word

bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# clear-scrollback-and-screen() {
#   zle clear-screen
#   tmux clear-history
# }
# zle -N clear-scrollback-and-screen
# bindkey '^[L' clear-scrollback-and-screen
