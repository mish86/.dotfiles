#!/bin/bash

# tmux fixes
# https://stackoverflow.com/questions/6205157/how-to-set-keyboard-shortcuts-to-jump-to-beginning-end-of-line
# https://stackoverflow.com/questions/12335787/with-iterm2-on-mac-how-to-delete-forward-a-word-from-cursor-on-command-line
# bindkey '^[b' backward-word
# bindkey '^[f' forward-word

bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey '^[^?' backward-kill-word
bindkey '^[[3;3~' kill-word

#bindkey '^R' history-incremental-search-backward
#bindkey '^S' history-incremental-search-forward
# bindkey '^P' up-history
# bindkey '^D' delete-char-or-list

clear-scrollback-and-screen() {
  zle clear-screen
  tmux clear-history
}
zle -N clear-scrollback-and-screen
bindkey '^[L' clear-scrollback-and-screen
