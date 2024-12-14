#!/bin/bash

[ ! -d "$(brew --prefix)" ] && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# dotfiles management
# https://www.gnu.org/software/stow/ https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html?round=two
brew install stow

# brew install bash

# -------- #
# Terminal #
# -------- #

# https://alacritty.org/
brew install alacritty

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
# syntax highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
brew install zsh-syntax-highlighting

# terminal multiplexer
brew install tmux
# install tmux plugins
git clone https://github.com/tmux-plugins/tpm "$HOME/.dotfiles/tmux/plugins/tpm"
# tmuxifier
# git clone https://github.com/jimeh/tmuxifier.git "$HOME/.config/tmuxifier"
brew install cmatrix

# text editor
# https://neovim.io/
brew install neovim

# terminal file manager
# https://yazi-rs.github.io/
brew install yazi

# https://github.com/ajeetdsouza/zoxide
brew install zoxide

# modern ls
# https://eza.rocks/
brew install eza

# fuzzy finder
# https://github.com/junegunn/fzf
brew install fzf
# bash and zsh key bindings for Git objects, powered by fzf
# https://github.com/junegunn/fzf-git.sh
git clone https://github.com/junegunn/fzf-git.sh.git "$HOME/.dotfiles/fzf-git"

# ripgrep recursively searches directories for a regex pattern while respecting your gitignore
# https://github.com/BurntSushi/ripgrep?tab=readme-ov-file#installation
brew install ripgrep
# https://github.com/sharkdp/fd
# A simple, fast and user-friendly alternative to 'find'
brew install fd

# A cat(1) clone with wings.
# https://github.com/sharkdp/bat?tab=readme-ov-file#installation
brew install bat

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
# https://github.com/ouch-org/ouch?tab=readme-ov-file#installation
brew install ouch

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

# https://dandavison.github.io/delta/
brew install git-delta
# https://github.com/jesseduffield/lazygit
brew install lazygit
# https://pre-commit.com/
brew install pre-commit

# ------ #
# DevKit #
# ------ #
brew install pip
brew install pipx
brew install pyenv
brew install node
brew install openjdk
brew install maven

# ------ #
# DevOps #
# ------ #
# https://developer.hashicorp.com/terraform/install#darwin
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
brew install awscli

# ---------- #
# containers #
# ---------- #
brew install podman

# --------- #
# DataBases #
# --------- #
brew install mongosh
# podman pull arangodb/arangodb
# podman run --rm -it arangodb/arangodb:latest arangosh

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

# macOS system monitor in your menu bar
# https://github.com/exelban/stats
brew install stats

# https://github.com/MonitorControl/MonitorControl
brew install MonitorControl

# https://github.com/tarutin/hovrly
brew install hovrly

# https://github.com/jordanbaird/Ice
brew install jordanbaird-ice

# https://dropoverapp.com
# AppStore

# https://www.mowglii.com/itsycal/
# Optional

# ----- #
# Theme #
# ----- #
# fonts
brew install font-hack-nerd-font
brew install font-meslo-lg-nerd-font
# catppuccin
git clone https://github.com/catppuccin/alacritty.git "$HOME/.dotfiles/catppuccin/alacritty"
git clone https://github.com/catppuccin/iterm.git "$HOME/.dotfiles/catppuccin/iterm"
git clone https://github.com/catppuccin/bat.git "$HOME/.dotfiles/catppuccin/bat"
git clone https://github.com/catppuccin/lazygit.git "$HOME/.dotfiles/catppuccin/lazygit"
git clone https://github.com/yazi-rs/flavors.git "$HOME/.dotfiles/yazi/flavors"
git clone https://github.com/yazi-rs/plugins.git "$HOME/.dotfiles/yazi/plugins"
