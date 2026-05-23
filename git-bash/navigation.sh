#!/usr/bin/env bash

# Enable forward search with Ctrl-S (disables terminal flow control)
[[ $- == *i* ]] && stty -ixon 2>/dev/null

# Shell options (bash equivalents of zsh setopt)
shopt -s autocd       2>/dev/null   # cd by typing a dir name
shopt -s cdspell                    # autocorrect minor typos in cd
shopt -s dirspell     2>/dev/null   # autocorrect dir names during completion
shopt -s dotglob                    # include dotfiles in globs (zsh globdots)
shopt -s globstar                   # ** recursive globbing
shopt -s extglob                    # extended globbing
shopt -s checkwinsize               # update LINES/COLUMNS after each cmd
shopt -s no_empty_cmd_completion    # don't complete on empty line

# CDPATH: ergonomic cd from home
# export CDPATH=".:$HOME:$HOME/projects"

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
