# ~/.bashrc - Git Bash on Windows

# aws cli and ssm plugin manually installed with no admin privileges
export PATH="$PATH:$LOCALAPPDATA/Amazon/AWSCLIV2"
export PATH="$PATH:$LOCALAPPDATA/Amazon/SessionManagerPlugin"
# unknown CA certificate
alias aws='aws --no-verify-ssl 2>/dev/null '

# Only run for interactive shells
case $- in
  *i*) ;;
    *) return ;;
esac

BASH_CFG="$HOME/.config/git-bash"

source "$BASH_CFG/bash_env.sh"
source "$BASH_CFG/maven.sh"
source "$BASH_CFG/navigation.sh"
source "$BASH_CFG/history.sh"
source "$BASH_CFG/aliases.sh"
source "$BASH_CFG/bindings.sh"
source "$BASH_CFG/completion.sh"

# Tools - sourced only when the binary is on PATH
command -v fzf     &>/dev/null && source "$BASH_CFG/fzf.sh"
command -v bat     &>/dev/null && source "$BASH_CFG/bat.sh"
command -v lazygit &>/dev/null && source "$BASH_CFG/lazygit.sh"
command -v zoxide  &>/dev/null && source "$BASH_CFG/zoxide.sh"
command -v kubectl &>/dev/null && source "$BASH_CFG/kube.sh"
command -v aws     &>/dev/null && source "$BASH_CFG/aws.sh"

# yazi: defines the `y` wrapper that cd's to the last yazi directory
command -v yazi &>/dev/null && source "$BASH_CFG/yazi.sh"

# Prompt - load last so it can override anything above
# source "$BASH_CFG/prompt.sh"

unset BASH_CFG
