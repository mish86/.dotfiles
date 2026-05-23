#!/usr/bin/env bash

# Minimal git-aware prompt for Git Bash.
# Git for Windows ships /etc/profile.d/git-prompt.sh which defines __git_ps1.

GIT_PROMPT_SH=""
for f in \
  /mingw64/share/git/completion/git-prompt.sh \
  /etc/profile.d/git-prompt.sh \
  /usr/share/git-core/contrib/completion/git-prompt.sh ; do
  if [[ -r "$f" ]]; then
    GIT_PROMPT_SH="$f"
    break
  fi
done
[[ -n "$GIT_PROMPT_SH" ]] && source "$GIT_PROMPT_SH"

# __git_ps1 settings (only meaningful if it's available)
export GIT_PS1_SHOWDIRTYSTATE=1       # *unstaged, +staged
export GIT_PS1_SHOWSTASHSTATE=1       # $ if stashed
export GIT_PS1_SHOWUNTRACKEDFILES=1   # %  if untracked
export GIT_PS1_SHOWUPSTREAM='auto'    # <, >, <> vs upstream
export GIT_PS1_SHOWCOLORHINTS=1

# ANSI colors (catppuccin-ish frappe palette)
C_USER='\[\e[38;5;110m\]'     # blue
C_HOST='\[\e[38;5;108m\]'     # green
C_PATH='\[\e[38;5;180m\]'     # yellow
C_GIT='\[\e[38;5;176m\]'      # mauve
C_RESET='\[\e[0m\]'

# kubectl context/namespace indicator.
# Cached on $KUBECONFIG mtime — kubectl is only spawned when the config
# changes (kctx/kns both rewrite it, so the cache updates on switch).
# Uses raw \001/\002 wrappers around escapes: bash decodes \[ \] before
# expanding variables, so embedding \[ \] inside __KUBE_PS1 wouldn't work.
__kube_ps1() {
  command -v kubectl &>/dev/null || { __KUBE_PS1=""; return; }

  local kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
  if [[ ! -r "$kubeconfig" ]]; then
    __KUBE_PS1=""
    __KUBE_PS1_MTIME=""
    return
  fi

  local mtime
  mtime=$(stat -c %Y "$kubeconfig" 2>/dev/null)
  if [[ -n "$mtime" && "$mtime" == "$__KUBE_PS1_MTIME" ]]; then
    return
  fi
  __KUBE_PS1_MTIME="$mtime"

  local ctx ns
  ctx=$(kubectl config current-context 2>/dev/null) || { __KUBE_PS1=""; return; }
  ns=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
  [[ -z "$ns" ]] && ns="default"

  local mauve=$'\001\e[38;5;176m\002'
  local reset=$'\001\e[0m\002'
  __KUBE_PS1=" ${mauve}[${ctx}:${ns}]${reset}"
}

if declare -F __git_ps1 >/dev/null 2>&1; then
  # __git_ps1 substitutes its arg, with %s as branch placeholder.
  # ${__KUBE_PS1} stays literal in PROMPT_COMMAND so bash (promptvars)
  # expands it each time PS1 is rendered.
  PROMPT_COMMAND="__kube_ps1; __git_ps1 '${C_USER}\u${C_RESET}@${C_HOST}\h${C_RESET} ${C_PATH}\w${C_RESET}\${__KUBE_PS1}' '\n\$ ' ' ${C_GIT}(%s)${C_RESET}'${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
else
  PROMPT_COMMAND="__kube_ps1${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
  PS1="${C_USER}\u${C_RESET}@${C_HOST}\h${C_RESET} ${C_PATH}\w${C_RESET}\${__KUBE_PS1}\n\$ "
fi

unset C_USER C_HOST C_PATH C_GIT C_RESET GIT_PROMPT_SH
