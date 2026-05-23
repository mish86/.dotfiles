#!/usr/bin/env bash

# yazi: open the file manager and, on exit, cd to the last visited dir.
# Mirrors the recommended `y` helper from yazi docs.
command -v yazi &>/dev/null || return 0

yy() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd" || return
  fi
  rm -f -- "$tmp"
}

# Source any extra yazi shell snippets you ship alongside the config
[[ -f "$HOME/.config/yazi/yazi_scripts.sh" ]] && source "$HOME/.config/yazi/yazi_scripts.sh"
