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
# CSI u: tmux extended-keys sends Shift+key as \e[CODE;2u
# Generic widget to insert the character from any CSI u sequence
csi-u-insert() {
  local key="${KEYS#$'\e['}"
  local code="${key%%;*}"
  if [[ -n "$code" ]] && (( code >= 32 && code <= 126 )); then
    printf -v REPLY "\\$(printf '%03o' "$code")"
    LBUFFER+="$REPLY"
  fi
}
zle -N csi-u-insert
for code in {32..126}; do
  bindkey "\e[${code};2u" csi-u-insert
done

# Shift+Enter inserts newline (overrides the generic binding above)
shift-enter-newline() { LBUFFER+=$'\n'; }
zle -N shift-enter-newline
bindkey '\e[13;2u' shift-enter-newline

# Up/Down: navigate lines in multi-line input, prefix history search otherwise
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
