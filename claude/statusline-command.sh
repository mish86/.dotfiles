#!/bin/sh
# Claude Code status line - styled after Starship config
# Receives JSON on stdin

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Directory: abbreviate $HOME to ~
if [ -n "$cwd" ]; then
  home="$HOME"
  dir="~${cwd#$home}"
else
  dir="$(pwd)"
fi

# Git info (skip optional locks)
git_branch=""
git_status=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  # Dirty indicator
  if ! git -C "$cwd" diff --quiet 2>/dev/null || ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
    git_status="*"
  fi
fi

# Time
time_str=$(date +%H:%M:%S)

# Context usage
ctx_str=""
if [ -n "$used_pct" ]; then
  ctx_str=$(printf "ctx:%.0f%%" "$used_pct")
fi

# Rate limits
five_hr=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate_str=""
if [ -n "$five_hr" ]; then
  rate_str=$(printf " 5h:%.0f%%" "$five_hr")
fi

# Build left side: dir + git
left=""
left="${left}in \033[34m${dir}\033[0m"
if [ -n "$git_branch" ]; then
  left="${left}  \033[33m${git_branch}${git_status}\033[0m"
fi

# Build right side: model + context + time
right=""
if [ -n "$model" ]; then
  right="\033[36m${model}\033[0m"
fi
if [ -n "$ctx_str" ]; then
  right="${right} \033[2m${ctx_str}${rate_str}\033[0m"
fi
right="${right} \033[2m${time_str}\033[0m"

printf "%b  %b\n" "$left" "$right"
