#!/bin/bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# dotfiles management
# https://www.gnu.org/software/stow/
# https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html?round=two
brew install stow

# brew install bash

# -------- #
# Terminal #
# -------- #

# system information tool
# https://github.com/dylanaraps/neofetch
brew install neofetch

# prompt for shell
# https://starship.rs/
brew install starship
# load default preset

# autosuggestions for zsh
# https://github.com/zsh-users/zsh-autosuggestions
brew install zsh-autosuggestions

# terminal multiplexer
brew install tmux
# install tmux plugins
# no need to stow
git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
# load config
tmux source "$HOME/.config/tmux/tmux.conf"
# tmuxifier
# no need to stow
git clone https://github.com/jimeh/tmuxifier.git "$HOME/.config/tmuxifier"

# text editor
# https://neovim.io/
brew install neovim

# terminal file manager
# https://yazi-rs.github.io/
brew install yazi

# modern ls
# https://eza.rocks/
brew install eza

# fuzzy finder
# https://github.com/junegunn/fzf
brew install fzf
# bash and zsh key bindings for Git objects, powered by fzf
# https://github.com/junegunn/fzf-git.sh
git clone https://github.com/junegunn/fzf-git.sh.git "$HOME/dotfiles/fzf-git"

# ripgrep recursively searches directories for a regex pattern while respecting your gitignore
# https://github.com/BurntSushi/ripgrep?tab=readme-ov-file#installation
brew install ripgrep
# https://github.com/sharkdp/fd
# A simple, fast and user-friendly alternative to 'find'
brew install fd

# A cat(1) clone with wings.
# https://github.com/sharkdp/bat?tab=readme-ov-file#installation
brew install bat

# https://dandavison.github.io/delta/
brew install git-delta
cat <<EOF >>"$HOME/.gitconfig"
[core]
  autocrlf = input
  editor = nvim
  pager = delta

[interactive]
  diffFilter = delta --color-only

[delta]
  navigate = true    # use n and N to move between diff sections
  side-by-side = true

    # delta detects terminal colors automatically; set one of these to disable auto-detection
    # dark = true
    # light = true

[merge]
  conflictstyle = diff3

[diff]
  colorMoved = default
EOF

# tool for shell scripts
# https://github.com/charmbracelet/gum
brew install gum

# markdown on the CLI
# https://github.com/charmbracelet/glow
brew install glow

# --- #
# CLI #
# --- #

brew install watch

# K8s CLI tool
# https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#install-with-homebrew-on-macos
brew install kubectl
brew install kustomize

# JSON processor
# https://jqlang.github.io/jq/
brew install jq

# YAML processor
# https://mikefarah.gitbook.io/yq
brew install yq

# --- #
# GIT #
# --- #

brew install lazygit
brew install pre-commit

# ------ #
# DevKit #
# ------ #
brew install pip
brew install pipx
brew install node
brew install openjdk

# --------#
# Network #
# ------- #

# dnsmasq
brew install dnsmasq
# dig
brew install bind

# --- #
# OSX #
# --- #

# select default applications for document types
# https://github.com/moretension/duti
brew install duti
# map extensions to vscode
# https://stackoverflow.com/questions/43665346/can-somebody-explain-how-to-make-vscode-the-default-editor-on-osx/43665710#43665710
curl "https://raw.githubusercontent.com/github/linguist/master/lib/linguist/languages.yml" |
  yq -r "to_entries | (map(.value.extensions) | flatten) - [null] | unique | .[]" |
  xargs -L 1 -I "{}" duti -s com.microsoft.VSCode {} all

# macOS system monitor in your menu bar
# https://github.com/exelban/stats
brew install stats

# ----- #
# Theme #
# ----- #
# fonts
brew install font-hack-nerd-font
brew install font-meslo-lg-nerd-font
# catppuccin
# for stow
git clone https://github.com/catppuccin/iterm.git "$HOME/.dotfiles/catppuccin/iterm"
git clone https://github.com/catppuccin/bat.git "$HOME/.dotfiles/catppuccin/bat"
git clone https://github.com/catppuccin/lazygit.git "$HOME/.dotfiles/catppuccin/lazygit"
git clone https://github.com/yazi-rs/flavors.git "$HOME/.dotfiles/yazi/flavors"
git clone https://github.com/yazi-rs/plugins.git "$HOME/.dotfiles/yazi/plugins"

# ---- #
# stow #
# ---- #
# cd "$HOME/dotfiles"
# catppuccin goes first
# mkdir -p "$HOME/.config/catppuccin"
# stow catppuccin -t "$HOME/.config/catppuccin" --adopt -vvv
# mkdir -p "$HOME/.config/alacritty"
# stow alacritty -t "$HOME/.config/alacritty" --adopt -vvv
# mkdir -p "$HOME/.config/bat"
# stow bat -t "$HOME/.config/bat" --adopt -vvv
# mkdir -p "$HOME/.config/fzf-git"
# stow fzf-git -t "$HOME/.config/fzf-git" --adopt
# mkdir -p "$HOME/.config/lazygit"
# stow lazygit -t "$HOME/.config/lazygit" --adopt
# mkdir -p "$HOME/.config/nvim"
# stow nvim -t "$HOME/.config/nvim" --adopt
# mkdir -p "$HOME/.config/tmux"
# stow tmux -t "$HOME/.config/tmux" --adopt
# mkdir -p "$HOME/.config/yazi"
# stow yazi -t "$HOME/.config/yazi" --adopt
# mkdir -p "$HOME/.config/zsh"
# stow zsh -t "$HOME/.config/zsh" --adopt
# .zshrc
# stow home -t $HOME --adopt -vvv
