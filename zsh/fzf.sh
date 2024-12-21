#!/bin/bash
# ---------
# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

source <(fzf --zsh)

# fzf theme: https://github.com/catppuccin/fzf
FZF_MOCHA_COLORS=" \
--color='bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8' \
--color='fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc' \
--color='marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'
--multi"

FZF_MACCHIATO_COLORS=" \
--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
--color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 \
--color=selected-bg:#494d64 \
--multi"

# --tmux options does not work in FZF_DEFAULT_OPTS
export FZF_TMUX_OPTS="-p 80%,80%"
export FZF_DEFAULT_OPTS="--height '50%' --tmux 'center,80%,50%' \
--border sharp \
--layout reverse \
$FZF_MACCHIATO_COLORS \
--prompt '> ' \
--pointer '▶' \
--marker '┃'"

# fzf commands
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'eza --tree --color=always {} | head -200'"
export FZF_COMPLETION_DIR_COMMANDS="cd pushd rmdir tree ls eza"


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

# https://news.ycombinator.com/item?id=38471822
# https://github.com/junegunn/fzf/blob/master/ADVANCED.md#switching-between-ripgrep-mode-and-fzf-mode-using-a-single-key-binding
function frg {
  result=$(rg --ignore-case --color=always --line-number --no-heading "$@" |
    fzf --ansi \
      --color 'hl:-1:underline,hl+:-1:underline:reverse' \
      --delimiter ':' \
      --preview "bat --color=always {1} --highlight-line {2}")
  file=${result%%:*}
  linenumber=$(echo "${result}" | cut -d: -f2)
  if [[ -n "$file" ]]; then
    $EDITOR +"${linenumber}" "$file"
  fi
}

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
    ID="$ID\n${create_new_session}"
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

git_pull_all() {
  git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
  git fetch --all
  git pull --all
}
