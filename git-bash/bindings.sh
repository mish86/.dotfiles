#!/usr/bin/env bash

# Readline keybindings-Citrix-friendly (no Alt/Meta).
# Citrix from macOS does not forward Alt reliably, so this file sticks to
# Ctrl + arrow / Ctrl + letter combos that pass through cleanly.
#
# Bash defaults already handle: Ctrl+A, Ctrl+E, Ctrl+W, Ctrl+U, Ctrl+K,
# Ctrl+R, Ctrl+L, Ctrl+T (transpose). No need to rebind those.

# --- Word movement: Ctrl+Left / Ctrl+Right ---
# Windows Terminal + Git Bash send these sequences.
bind '"\e[1;5D": backward-word' 2>/dev/null
bind '"\e[1;5C": forward-word'  2>/dev/null

# --- Word delete: Ctrl+Backspace / Ctrl+Delete ---
# Ctrl+Backspace in Git Bash typically arrives as ^H (0x08).
# Ctrl+W (default) only deletes whitespace-delimited words; this version
# respects word boundaries (punctuation, slashes).
bind '"\C-h": backward-kill-word' 2>/dev/null
bind '"\e[3;5~": kill-word'       2>/dev/null

# --- Prefix history search on Up/Down ---
# Type "git " then Up cycles through past commands that started with "git ".
# Far more useful than plain history scrolling.
bind '"\e[A": history-search-backward' 2>/dev/null
bind '"\e[B": history-search-forward'  2>/dev/null

# --- Completion behavior ---
bind 'set completion-ignore-case on'      2>/dev/null   # tab is case-insensitive
bind 'set completion-map-case on'         2>/dev/null   # treat-and _ as equal
bind 'set show-all-if-ambiguous on'       2>/dev/null   # single tab shows matches
bind 'set show-all-if-unmodified on'      2>/dev/null
bind 'set colored-stats on'               2>/dev/null   # color file types
bind 'set colored-completion-prefix on'   2>/dev/null
bind 'set mark-symlinked-directories on'  2>/dev/null
bind 'set visible-stats on'               2>/dev/null   # append /, *, @ like ls -F
bind 'set bell-style none'                2>/dev/null   # no terminal bell
