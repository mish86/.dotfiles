#!/usr/bin/env bash
# Wrapper around tmux-agent-indicator's agent-state.sh for Claude Code hooks.
# The plugin's own notification is disabled (@agent-indicator-notification-enabled off)
# because it fires for every window; this notifies only when the source pane's
# window is the currently viewed window of its session.

PLUGIN_DIR="${TMUX_AGENT_INDICATOR_DIR:-$HOME/.config/tmux/plugins/tmux-agent-indicator}"
"$PLUGIN_DIR/scripts/agent-state.sh" "$@"

[ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ] || exit 0

agent=""
state=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --agent) agent="$2"; shift 2 ;;
        --state) state="$2"; shift 2 ;;
        *) shift ;;
    esac
done

case "$state" in
    needs-input|done) ;;
    *) exit 0 ;;
esac

# #{window_active}: is the pane's window the current window of its session?
active=$(tmux display-message -p -t "$TMUX_PANE" '#{window_active}' 2>/dev/null)
[ "$active" = "1" ] || exit 0

tmux display-message -d 5000 -t "$TMUX_PANE" "[$agent] $state (#S:#W)" 2>/dev/null || true
