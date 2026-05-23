#!/usr/bin/env bash

# zoxide: smarter cd. `z <fragment>` jumps to a frecent dir, `zi` opens fzf picker.
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"
