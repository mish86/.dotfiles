#!/bin/bash

# brew
[ ! -d "$(brew --prefix)" ] &&
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# https://github.com/mas-cli/mas
brew install mas

# dotfiles management
# https://www.gnu.org/software/stow/ https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html?round=two
brew install stow

# brew install bash

# -------- #
# Terminal #
# -------- #
echo "=== installing terminal and tools ==="
# https://alacritty.org/
brew install alacritty
# https://ghostty.org
brew install ghostty

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
# system information tool
# https://github.com/dylanaraps/neofetch
brew install neofetch
# https://github.com/ClementTsang/bottom?tab=readme-ov-file#homebrew
# brew install bottom
# https://github.com/aristocratos/btop?tab=readme-ov-file#installation
# brew install btop

# text editor
# https://neovim.io/
brew install neovim
# https://code.visualstudio.com/download
# vscode

# --- #
# CLI #
# --- #
echo "=== installing cli tools ==="
brew install watch
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

# https://github.com/charmbracelet/sequin
# brew install charmbracelet/tap/sequin

# markdown on the CLI
# https://github.com/charmbracelet/glow
brew install glow

# https://github.com/ouch-org/ouch?tab=readme-ov-file#installation
brew install ouch

# --- #
# K8s #
# --- #
echo "=== installing k8s cli tools ==="
# https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#install-with-homebrew-on-macos
brew install kubectl
# https://kubecolor.github.io/setup/install/
brew install kubecolor
brew install kustomize
# brew install derailed/k9s/k9s

# JSON processor
# https://jqlang.github.io/jq/
brew install jq

# YAML processor
# https://mikefarah.gitbook.io/yq
brew install yq

# --- #
# GIT #
# --- #
echo "=== installing git and git tools ==="
# https://dandavison.github.io/delta/
brew install git-delta
# https://github.com/jesseduffield/lazygit
brew install lazygit
brew install lazydocker
# https://pre-commit.com/
brew install pre-commit

# ------ #
# DevKit #
# ------ #
echo "=== installing devkits ==="
brew install pip
brew install pipx
brew install pyenv
brew install node
brew install openjdk
brew install maven

# ------ #
# DevOps #
# ------ #
echo "=== installing devops tools ==="
# https://developer.hashicorp.com/terraform/install#darwin
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
brew install awscli

# ---------- #
# containers #
# ---------- #
brew install podman
brew install kind
brew install kubebuilder

# --------- #
# DataBases #
# --------- #
brew install mongosh
# podman pull arangodb/arangodb
# podman run --rm -it arangodb/arangodb:latest arangosh
brew install --cask dbeaver-community
brew install --cask studio-3t

# ------ #
# DevOps #
# ------ #
# https://developer.hashicorp.com/terraform/install#darwin
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
brew install awscli

# --------#
# Network #
# ------- #
echo "=== installing network tools ==="
# dnsmasq
brew install dnsmasq
# dig
brew install bind
# HTTP load generator
# https://github.com/rakyll/hey
brew install hey

# ------------ #
# UI dev tools #
# ------------ #

# https://code.visualstudio.com/docs/setup/mac

# --- #
# OSX #
# --- #
echo "=== installing essential ==="
# select default applications for document types
# https://github.com/moretension/duti
brew install duti

# macOS system monitor in your menu bar
# https://github.com/exelban/stats
brew install stats

# https://github.com/MonitorControl/MonitorControl
# brew install MonitorControl
# https://lunar.fyi/

# https://github.com/tarutin/hovrly
brew install hovrly

# https://github.com/jordanbaird/Ice
brew install jordanbaird-ice

# https://dropoverapp.com
# AppStore

# https://www.mowglii.com/itsycal/
# Optional

# https://www.caffeine-app.net/
brew install caffeine

# --------------- #
# Windows Manager #
# --------------- #
echo "=== installing windows manager ==="
mac install 441258766 # Magent

# https://nikitabobko.github.io/AeroSpace/guide#homebrew-installation
# brew install --cask nikitabobko/tap/aerospace

# https://github.com/rxhanson/Rectangle
# brew install --cask rectangle

# https://felixkratz.github.io/SketchyBar/setup
# brew tap FelixKratz/formulae
# brew install sketchybar
# brew install borders

# ----- #
# Theme #
# ----- #
echo "=== installing fonts and theme ==="
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
curl -L https://github.com/catppuccin/k9s/archive/main.tar.gz | tar xz -C "$HOME/.dotfiles/k9s/skins" --strip-components=2 k9s-main/dist
