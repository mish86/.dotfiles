#!/bin/bash

bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
# Shift+arrows: word movement
bindkey '^[[1;2D' backward-word
bindkey '^[[1;2C' forward-word
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey '^[^?' backward-kill-word
bindkey '^[[3;3~' kill-word
bindkey '^[^M' self-insert-unmeta
# Shift+Enter inserts newline (multi-line editing) — CSI u encoded
shift-enter-newline() { LBUFFER+=$'\n'; }
zle -N shift-enter-newline
bindkey '\e[13;2u' shift-enter-newline

# Up/Down: navigate lines in multi-line input, prefix history search otherwise
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
