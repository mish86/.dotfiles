#!/bin/bash

# --------------- #
# Windows Manager #
# --------------- #
# echo "=== setting up windows managers ==="
# https://felixkratz.github.io/SketchyBar/setup
# mkdir -p "$HOME/.config/sketchybar/plugins"
# cp $(brew --prefix)/share/sketchybar/examples/sketchybarrc "$HOME/.config/sketchybar/sketchybarrc"
# cp -r $(brew --prefix)/share/sketchybar/examples/plugins/ "$HOME/.config/sketchybar/plugins/"

# -------- #
# Terminal #
# -------- #
echo "=== setting up terminal tools ==="
git clone https://github.com/ndtoan96/ouch.yazi.git "$HOME/.dotfiles/yazi/plugins/ouch.yazi"
git clone https://github.com/Rolv-Apneseth/starship.yazi.git "$HOME/.dotfiles/yazi/plugins/starship.yazi"
git clone https://github.com/Lil-Dank/lazygit.yazi.git "$HOME/.dotfiles/yazi/plugins/lazygit.yazi"

# ---- #
# stow #
# ---- #
cd "$HOME/.dotfiles"
# catppuccin goes first
mkdir -p "$HOME/.config/catppuccin"
stow catppuccin -t "$HOME/.config/catppuccin" --adopt -v
mkdir -p "$HOME/.config/alacritty"
stow alacritty -t "$HOME/.config/alacritty" --adopt -v
mkdir -p "$HOME/.config/ghostty"
stow ghostty -t "$HOME/.config/ghostty" --adopt -v
mkdir -p "$HOME/.config/bat"
stow bat -t "$HOME/.config/bat" --adopt -v
mkdir -p "$HOME/.config/fzf-git"
stow fzf-git -t "$HOME/.config/fzf-git" --adopt -v
mkdir -p "$HOME/.config/lazygit"
stow lazygit -t "$HOME/.config/lazygit" --adopt -v
mkdir -p "$HOME/.config/nvim"
stow nvim -t "$HOME/.config/nvim" --adopt -v
mkdir -p "$HOME/.config/tmux"
stow tmux -t "$HOME/.config/tmux" --adopt -v
mkdir -p "$HOME/.config/yazi"
stow yazi -t "$HOME/.config/yazi" --adopt -v
mkdir -p "$HOME/.config/zsh"
stow zsh -t "$HOME/.config/zsh" --adopt -v
mkdir -p "$HOME/.config/starship"
stow starship -t "$HOME/.config/starship" --adopt -v
# mkdir -p "$HOME/.config/aerospace"
# stow aerospace -t "$HOME/.config/aerospace" --adopt -v
mkdir -p "$HOME/.config/k9s"
stow k9s -t "$HOME/.config/k9s" --adopt -v
# .zshrc
stow home -t $HOME --adopt -v


# load tmux config
tmux start-server
tmux source "$HOME/.config/tmux/tmux.conf"
# https://github.com/sharkdp/bat
bat cache --build

# ------ #
# DevKit #
# ------ #
pipx install argcomplete

# --------- #
# DataBases #
# --------- #
podman pull arangodb/arangodb

# --- #
# OSX #
# --- #
# https://felixkratz.github.io/SketchyBar/setup
# brew services start sketchybar
# brew services start borders

# --- #
# GIT #
# --- #

echo "=== setting up git config ==="
# setup git-delta
# https://github.com/dandavison/delta
if ! grep -q 'git-delta starts here' "$HOME/.gitconfig"; then
  cat <<EOF >>"$HOME/.gitconfig"
# git-delta starts here
# https://github.com/dandavison/delta
[core]
  autocrlf = input
  editor = nvim
  pager = delta

[interactive]
  diffFilter = delta --color-only

[delta]
  navigate = true    # use n and N to move between diff sections
  # side-by-side = true

    # delta detects terminal colors automatically; set one of these to disable auto-detection
    # dark = true
    # light = true

[merge]
  conflictstyle = diff3

[diff]
  colorMoved = default
# git-delta ends here
EOF
fi
