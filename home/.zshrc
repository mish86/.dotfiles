source "$HOME/.config/zsh/zsh_env.sh"
source "$HOME/.config/zsh/navigation.sh"
source "$HOME/.config/zsh/history.sh"
source "$HOME/.config/zsh/aliases.sh" 
source "$HOME/.config/zsh/bindings.sh"

# https://brew.sh/
[ -f '/opt/homebrew/bin/brew' ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# https://github.com/ryanoasis/nerd-fonts/releases
[[ starship ]] && eval "$(starship init zsh)"

# https://github.com/junegunn/fzf
[[ fzf ]] && source "$HOME/.config/zsh/fzf.sh"
[[ bat ]] && source "$HOME/.config/zsh/bat.sh"
[[ lazygit ]] && source "$HOME/.config/zsh/lazygit.sh"

# https://github.com/charmbracelet/gum
[[ gum ]] && source "$HOME/.config/zsh/gum_scripts.sh"

# https://github.com/sxyazi/yazi
source "$HOME/.config/yazi/yazi_scripts.sh"

# https://github.com/jimeh/tmuxifier
export PATH="$HOME/.config/tmuxifier/bin:$PATH"
[[ tmuxifier ]] && eval "$(tmuxifier init -)"

source "$HOME/.config/zsh/completion.sh"
# iterm2 integrations (e.g. for auto-marks)
test -e "$HOME/.config/zsh/iterm2_shell_integration.zsh" && source "$HOME/.config/zsh/iterm2_shell_integration.zsh" || true

