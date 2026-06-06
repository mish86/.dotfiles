#!/usr/bin/env bash

# Environment variables (Git Bash on Windows)

export XDG_CONFIG_HOME="$HOME/.config"

# editor (Git Bash ships vim; nvim not available without admin)
export VISUAL='vim'
export KUBE_EDITOR='vim'
export EDITOR='vim'

# Make sure UTF-8 is the default in Git Bash
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# Force Windows console code page to UTF-8 (65001)
command -v chcp.com &>/dev/null && chcp.com 65001 &>/dev/null

# Default flags for every `less` invocation (yours, git's, man's, kubectl's...).
#   -R                preserve ANSI colors from upstream tools
#   -F                quit if the content fits on one screen
#   -X                don't clear the screen on exit
#   --mouse           scrollwheel support (Windows Terminal forwards it)
#   --use-color       colorize less's own UI (prompts, status line)
# Git Bash ships less >= 608, so all flags are supported.
export LESS='-R -F -X --mouse --use-color'

# starship looks at ~/.config/starship.toml by default; our config lives
# one level deeper (matches the macOS layout).
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
