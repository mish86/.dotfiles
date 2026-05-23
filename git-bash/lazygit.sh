#!/usr/bin/env bash

# lazygit config: main config + theme.
# On Git Bash, $HOME maps to %USERPROFILE%; lazygit reads these paths fine.
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/rosewater.yml"
