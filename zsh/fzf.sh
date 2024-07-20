#!/bin/bash
# ---------
# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

source <(fzf --zsh)

# fzf
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
#export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# https://github.com/catppuccin/fzf
FZF_COLORS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

export FZF_DEFAULT_OPTS="--height 60% \
--border sharp \
--layout reverse \
$FZF_COLORS \
--prompt '> ' \
--pointer ▶ \
--marker ┃"
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'eza --tree --color=always {} | head -200'"
export FZF_COMPLETION_DIR_COMMANDS="cd pushd rmdir tree ls eza"

export FZF_TMUX_OPTS="-p"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
  cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
  export | unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
  ssh) fzf --preview 'dig {}' "$@" ;;
  *) fzf --preview 'bat -n --color=always --line-range :500 {}' "$@" ;;
  esac
}

# https://github.com/junegunn/fzf-git.sh
# GIT shortcuts
source "$HOME/.config/fzf-git/fzf-git.sh"
export KEYTIMEOUT=100
