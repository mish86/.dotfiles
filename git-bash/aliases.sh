#!/usr/bin/env bash

# Allow aliases to expand after sudo
# alias sudo='sudo '

# +----+
# | ls |
# +----+

if command -v eza &>/dev/null; then
  alias ls='eza'
  alias l='eza --oneline --long --hyperlink'
  alias ll='eza --oneline --long --hyperlink --icons=always --group-directories-first --all --sort=modified'
else
  alias ls='ls --color=auto'
  alias l='ls -lh --color=auto'
  alias ll='ls -lah --color=auto'
fi

# +-------------+
# | cp / mv /rm |
# +-------------+

alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'

# +-----+
# | zip |
# +-----+

# Windows ships bsdtar at C:\Windows\System32\tar.exe - it handles zip natively.
# (Git Bash's own `tar` is GNU tar and cannot do zip.)
if [[ -x /c/Windows/System32/tar.exe ]]; then
  alias zip='tar.exe -a -cf'    # zip out.zip file1 file2 dir/
  alias unzip='tar.exe -xf'     # unzip in.zip   (add -C dir/ to extract elsewhere)
  alias zipls='tar.exe -tf'     # zipls in.zip
fi

# +------+
# | grep |
# +------+

alias grep='grep -i --color=auto'

# +-----+
# | Vim |
# +-----+

# Git Bash ships vim. fvim picks files via fzf and opens them in vim.
if command -v fzf &>/dev/null && command -v bat &>/dev/null; then
  alias fvim='vim $(fzf -m --preview="bat --color=always --style=numbers --line-range=:500 {}")'
elif command -v fzf &>/dev/null; then
  alias fvim='vim $(fzf -m)'
fi

# +-----+
# | Git |
# +-----+

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
alias grb='git branch -r'
alias gplo='git pull origin'
alias gb='git branch '
alias gc='git commit'
alias gd='git diff'
alias gco='git checkout '
alias gl='git log --oneline'
alias gr='git remote'
alias grs='git remote show'
alias glol='git log --graph --abbrev-commit --oneline --decorate'
alias gclean="git branch --merged | grep -v '\\*\\|master\\|main\\|develop' | xargs -n 1 git branch -d"
alias gblog="git for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:red)%(refname:short)%(color:reset) - %(color:yellow)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:blue)%(committerdate:relative)%(color:reset))'"
alias gsub='git submodule update --remote'
alias gj='git-jump'

# Diff two files even if not in a git repo
alias dif='git diff --no-index'
