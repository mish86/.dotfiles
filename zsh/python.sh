#!/bin/bash

# python
export PATH="$(brew --prefix python)/libexec/bin:$PATH"
# export PATH="${HOMEBREW_PREFIX}/bin/python3:$PATH"

# pipx
# https://pipx.pypa.io/stable/
export PATH=".:$PATH:$HOME/.local/bin"
eval "$(register-python-argcomplete pipx)"

# pyenv
# https://github.com/pyenv/pyenv/issues/2918
# https://github.com/pyenv/pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
