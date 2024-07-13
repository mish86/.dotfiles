#!/bin/bash

# ---- #
# stow #
# ---- #
cd "$HOME/.dotfiles"
stow -D catppuccin -t "$HOME/.config/catppuccin" -v
stow -D alacritty -t "$HOME/.config/alacritty" -v
stow -D bat -t "$HOME/.config/bat" -v
stow -D fzf-git -t "$HOME/.config/fzf-git" -v
stow -D lazygit -t "$HOME/.config/lazygit" -v
stow -D nvim -t "$HOME/.config/nvim" -v
stow -D tmux -t "$HOME/.config/tmux" -v
stow -D yazi -t "$HOME/.config/yazi" -v
stow -D zsh -t "$HOME/.config/zsh" -v
# .zshrc
stow -D home -t $HOME -v
