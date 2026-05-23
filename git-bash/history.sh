#!/usr/bin/env bash

# history
# Generous but bounded. "Unlimited" works but huge files slow startup and grep.
export HISTSIZE=100000
export HISTFILESIZE=200000

# Timestamps in the file - invaluable for forensics, no downside.
export HISTTIMEFORMAT='%F %T  '

# Skip leading-space commands and consecutive duplicates. Standard.
export HISTCONTROL=ignoreboth

# Don't clutter history with trivial stuff.
export HISTIGNORE='ls:ll:cd:pwd:exit:clear:history:bg:fg'

# Append on exit instead of overwriting - prevents loss across parallel sessions.
shopt -s histappend

# Multi-line commands stored as one entry. On by default, but explicit is fine.
shopt -s cmdhist

# Flush each command to the file as it runs (so a crash doesn't lose it,
# and other sessions see it next time they start).
PROMPT_COMMAND="history -a; ${PROMPT_COMMAND:-:}"
