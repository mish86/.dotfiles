#!/bin/bash
# macOS Settings
# https://macos-defaults.com
# https://lupin3000.github.io/macOS/defaults/
echo '=== changing macOS defaults ==='
echo '=== Dock ==='
# show current dock settings
# defaults read com.apple.Dock
# reset to factory settings
# defaults delete com.apple.Dock
# active single app mode
defaults write com.apple.Dock single-app -bool true
# set icon size to 80 pixels
defaults write com.apple.Dock tilesize -int 80
# disable auto hide
defaults write com.apple.Dock autohide -bool false
# position bottom
defaults write com.apple.Dock orientation -string bottom
# enable animations when you open an application from the Dock
defaults write com.apple.Dock launchanim -bool true
# restart Dock
killall Dock

echo '=== Mission Control ==='
# rearrange Spaces automatically
defaults write com.apple.dock mru-spaces -bool false
# group windows by application
defaults write com.apple.dock expose-group-apps -bool true
# scroll up on a Dock icon to show all Space's opened windows for an app, or open stack.
defaults write com.apple.dock scroll-to-open -bool true
# restart Dock
killall Dock

echo '=== Finder ==='
# show current Finder settings
# defaults read com.apple.Finder
# show file extension
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# hide hidden files by default
defaults write com.apple.Finder AppleShowAllFiles -bool false
# show path bar in the bottom of the Finder windows
defaults write com.apple.Finder ShowPathbar -bool true
# show shorten path style instead of POSIX path
defaults write com.apple.Finder _FXShowPosixPathInTitle -bool false
# hide status bar
defaults write com.apple.Finder ShowStatusBar -bool false
# set list view style as default for folders without custom setting
defaults write com.apple.Finder FXPreferredViewStyle -string 'Nlsv'
# keep folders on top when sorting by name
defaults write com.apple.Finder _FXSortFoldersFirst -bool true
# open folders in a new tab, when using ⌘ + double-click and the option is shown in the context menu
defaults write com.apple.Finder FinderSpawnTab -bool true
# search in the current folder
defaults write com.apple.Finder FXDefaultSearchScope -string 'SCcf'
# do not display the warning, when changing a file extension
defaults write com.apple.Finder FXEnableExtensionChangeWarning -bool false
# size of Finder sidebar icons
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2
# show internal hard drives on desktop
defaults write com.apple.Finder ShowHardDrivesOnDesktop -bool false
# show external hard drives on desktop
defaults write com.apple.Finder ShowExternalHardDrivesOnDesktop -bool false
# show removable media on desktop
defaults write com.apple.Finder ShowRemovableMediaOnDesktop -bool false
# show mounted servers on desktop
defaults write com.apple.Finder ShowMountedServersOnDesktop -bool false
# restart Finder
killall Finder

