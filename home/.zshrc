source "$HOME/.config/zsh/zsh_env.sh"
source "$HOME/.config/zsh/navigation.sh"
source "$HOME/.config/zsh/history.sh"
source "$HOME/.config/zsh/aliases.sh"
source "$HOME/.config/zsh/bindings.sh"
source "$HOME/.config/zsh/completion.sh"

# https://brew.sh/
[ -f '/opt/homebrew/bin/brew' ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# iterm2 integrations (e.g. for auto-marks)
# test -e "$HOME/.config/zsh/iterm2_shell_integration.zsh" && 
  # source "$HOME/.config/zsh/iterm2_shell_integration.zsh" || true

# https://github.com/zsh-users/zsh-autosuggestions
[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && 
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && 
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# https://github.com/junegunn/fzf
command -v fzf &>/dev/null && source "$HOME/.config/zsh/fzf.sh"
command -v bat &>/dev/null && source "$HOME/.config/zsh/bat.sh"
command -v lazygit &>/dev/null && source "$HOME/.config/zsh/lazygit.sh"
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# https://github.com/charmbracelet/gum
# [[ gum ]] && source "$HOME/.config/zsh/gum_scripts.sh"

# https://github.com/sxyazi/yazi
source "$HOME/.config/yazi/yazi_scripts.sh"

# https://github.com/jimeh/tmuxifier
# export PATH="$HOME/.config/tmuxifier/bin:$PATH"
# [[ tmuxifier ]] && eval "$(tmuxifier init -)"

source "$HOME/.config/zsh/kube.sh"
source "$HOME/.config/zsh/python.sh"
source "$HOME/.config/zsh/go.sh"
source "$HOME/.config/zsh/azure_cli.sh"
# source "$HOME/.config/zsh/litmus.sh"

# https://github.com/ryanoasis/nerd-fonts/releases
[[ starship ]] && \
  export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml" && \
  eval "$(starship init zsh)"

