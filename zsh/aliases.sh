#!/bin/bash
# https://github.com/Phantas0s/.dotfiles/blob/master/aliases/aliases

# allow use aliases with sudo
alias sudo='sudo '

# +-----+
# | Zsh |
# +-----+

# used in fpop with fzf
# alias d='dirs -v'
# for index ({1..9}) alias "$index"="cd +${index} > /dev/null"; unset index # directory stack

# +----+
# | ls |
# +----+

alias ls='eza'
alias l='eza --oneline --long'
alias ll='eza --oneline --long --icons=always --group-directories-first --all --sort=modified'

# +----+
# | cp |
# +----+

alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'

# +------+
# | grep |
# +------+

alias grep="grep -i --color=auto"

# +--------+
# | Neovim |
# +--------+

alias fvim='nvim $(fzf -m --preview="bat --color=always --style=numbers --line-range=:500 {}")'
alias vim='nvim'
#alias vi='nvim'
#alias lvim='\vim -c "set nowrap|syntax off"'        # fast vim for big files / big oneliner
alias vi='\vim -c "set nu" -c "set nowrap|syntax off"'

# +-----+
# | Git |
# +-----+

alias gs='git status'
alias gss='git status -s'
alias ga='git add'
alias gp='git push'
alias gpraise='git blame'
alias gpo='git push origin'
alias gpof='git push origin --force-with-lease'
alias gpofn='git push origin --force-with-lease --no-verify'
alias gpt='git push --tag'
alias gtd='git tag --delete'
alias gtdr='git tag --delete origin'
alias grb='git branch -r' # display remote branch
alias gplo='git pull origin'
alias gb='git branch '
alias gc='git commit'
alias gd='git diff'
alias gco='git checkout '
alias gl='git log --oneline'
alias gr='git remote'
alias grs='git remote show'
alias glol='git log --graph --abbrev-commit --oneline --decorate'
alias gclean="git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 git branch -d"                                                                                                                                                                             # Delete local branch merged with master
alias gblog="git for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:red)%(refname:short)%(color:reset) - %(color:yellow)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:blue)%(committerdate:relative)%(color:reset))'" # git log for each branches
alias gsub="git submodule update --remote"                                                                                                                                                                                                                                    # pull submodules
alias gj="git-jump"                                                                                                                                                                                                                                                           # Open in vim quickfix list files of interest (git diff, merged...)

alias dif="git diff --no-index" # Diff two files even if not in git repo! Can add -w (don't diff whitespaces)

# +------+
# | tmux |
# +------+

alias tmuxk='tmux kill-session -t'
alias tmuxa='tmux attach -t'
alias tmuxl='tmux list-sessions'

# +---------+
# | kubectl |
# +---------+

alias ctx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config get-contexts -o name | gum filter | xargs kubectl config use-context; }; f'
alias ns='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl get ns  --no-headers -o custom-columns=":metadata.name" | gum filter | xargs kubectl config set-context --current --namespace; kubectl config view --minify | grep namespace | cut -d" " -f6 }; f'
alias k8s='f() {
  context=$(kubectl config get-contexts -o name | gum filter) || return 130
  namespace=$(kubectl get ns --no-headers -o custom-columns=":metadata.name" | gum filter) || return 130
  kubectl --context $context --namespace $namespace "$@"
}; f'

# dotfiles
# https://gist.github.com/ennanco/d1c6a228f5aac23a3af6592135f0f8ae
alias dotfiles="git --git-dir=$DOTFILES --work-tree=$HOME"
