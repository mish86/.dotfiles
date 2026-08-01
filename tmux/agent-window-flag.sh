#!/usr/bin/env bash
# Agent prefix for a window tab (used in @catppuccin_window_*_text).
# Usage: agent-window-flag.sh <window_id>
# Prints "🤖<state glyph> " when an agent pane exists in the window:
#   🤖✳ running (blue) | 🤖● needs input (yellow, blinking) | 🤖✔ done (green)
#   🤖 idle (agent present, detected via pane_current_command)
# States come from TMUX_AGENT_PANE_<pane>_STATE env vars set by tmux-agent-indicator hooks.

win="$1"
[ -n "$win" ] || exit 0

best=""
present=""
while IFS=' ' read -r pane cmd; do
    case "$cmd" in
        claude|codex|aider|opencode|cursor) present=1 ;;
    esac
    state=$(tmux show-environment -g "TMUX_AGENT_PANE_${pane}_STATE" 2>/dev/null | cut -d= -f2-)
    case "$state" in
        needs-input) best="needs-input" ;;
        running)     [ "$best" = "needs-input" ] || best="running" ;;
        done)        [ -n "$best" ] || best="done" ;;
    esac
done < <(tmux list-panes -t "$win" -F '#{pane_id} #{pane_current_command}' 2>/dev/null)

# catppuccin frappe: blue #8caaee, yellow #e5c890, green #a6d189
case "$best" in
    running)     printf '🤖 #[fg=#8caaee bold]✳#[nobold] ' ;;
    needs-input) # blink on alternate status-interval ticks (interval is 2s)
        if [ $(( $(date +%s) / 2 % 2 )) -eq 0 ]; then
            printf '🤖 #[fg=#e5c890 bold]●#[nobold] '
        else
            printf '🤖  '
        fi ;;
    done)        printf '🤖 #[fg=#a6d189 bold]✔#[nobold] ' ;;
    *)           [ -n "$present" ] && printf '🤖 ' ;;
esac
exit 0
