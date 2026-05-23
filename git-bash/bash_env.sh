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

# Default flags for every `less` invocation (yours, git's, man's, kubectl's...).
#   -R                preserve ANSI colors from upstream tools
#   -F                quit if the content fits on one screen
#   -X                don't clear the screen on exit
#   --mouse           scrollwheel support (Windows Terminal forwards it)
#   --use-color       colorize less's own UI (prompts, status line)
# Git Bash ships less >= 608, so all flags are supported.
export LESS='-R -F -X --mouse --use-color'
