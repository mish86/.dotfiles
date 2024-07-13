#!/bin/bash

# https://github.com/Phantas0s/.dotfiles/blob/master/zsh/zshenv

###############################
# EXPORT ENVIRONMENT VARIABLE #
###############################

export DOTFILES="$HOME/.cfg"
# required for lazygit config home dir
# https://github.com/jesseduffield/lazygit/blob/master/docs/Config.06/02/2024
export XDG_CONFIG_HOME="$HOME/.config"

# editor
export VISUAL='nvim'
export KUBE_EDITOR='nvim'
export EDITOR='nvim'
