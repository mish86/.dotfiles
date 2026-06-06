# starship prompt. Bash gets the full integration (PROMPT_COMMAND hooks,
# preexec for cmd_duration, transient prompt)-all features the busybox
# ash version can't have.
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
