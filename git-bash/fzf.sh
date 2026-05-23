#!/usr/bin/env bash

# fzf integration for Git Bash on Windows.
# Install: `scoop install fzf`. Bash bindings are bundled with fzf >= 0.48.

# Keybindings + completion
if command -v fzf &>/dev/null; then
  # Modern fzf exposes shell init via `fzf --bash`
  eval "$(fzf --bash)" 2>/dev/null || true
fi

# catppuccin frappe theme
FZF_FRAPPE_COLORS=" \
--color=bg+:#414559,bg:#303446,spinner:#F2D5CF,hl:#E78284 \
--color=fg:#C6D0F5,header:#E78284,info:#CA9EE6,pointer:#F2D5CF \
--color=marker:#BABBF1,fg+:#C6D0F5,prompt:#CA9EE6,hl+:#E78284 \
--color=selected-bg:#51576D \
--color=border:#737994,label:#C6D0F5"

export FZF_DEFAULT_OPTS="--height '50%' \
--border sharp \
--layout reverse \
$FZF_FRAPPE_COLORS \
--prompt '> ' \
--pointer '>' \
--marker '|'"

# Use ripgrep if installed
if command -v rg &>/dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
fi

# Ctrl-R: copy command to clipboard with Ctrl-Y (uses Git Bash `clip`)
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | clip)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

# Ctrl-T preview
if command -v bat &>/dev/null; then
  export FZF_CTRL_T_OPTS="
    --walker-skip .git,node_modules,target
    --preview 'bat -n --color=always {}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"
else
  export FZF_CTRL_T_OPTS="
    --walker-skip .git,node_modules,target
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"
fi

# Alt-C preview (directory)
if command -v eza &>/dev/null; then
  export FZF_ALT_C_OPTS="
    --walker-skip .git,node_modules,target
    --preview 'eza --tree --color=always {} | head -200'"
else
  export FZF_ALT_C_OPTS="
    --walker-skip .git,node_modules,target
    --preview 'ls --color=always {}'"
fi

export FZF_COMPLETION_DIR_COMMANDS="cd pushd rmdir tree ls eza"

# rg + fzf: search content, open match in $EDITOR at the right line
frg() {
  local result file linenumber
  result=$(rg --ignore-case --color=always --line-number --no-heading "${*:-}" |
    fzf --ansi \
      --color 'hl:-1:underline,hl+:-1:underline:reverse' \
      --delimiter ':' \
      --preview "bat --color=always {1} --highlight-line {2}")
  file=${result%%:*}
  linenumber=$(echo "${result}" | cut -d: -f2)
  if [[ -n "$file" ]]; then
    "${EDITOR:-vim}" +"${linenumber}" "$file"
  fi
}
