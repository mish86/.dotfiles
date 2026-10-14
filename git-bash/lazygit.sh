#!/usr/bin/env bash

# lazygit config: main config + theme.
# lazygit is a native Windows binary, so it needs Windows paths
# (C:/Users/...), not MSYS paths (/c/Users/...). Git Bash auto-converts only
# the first entry of a comma-joined value, so convert both with cygpath.
export LG_CONFIG_FILE="$(cygpath -m ~/.config/lazygit/config.yml),$(cygpath -m ~/.config/lazygit/rosewater.yml)"
