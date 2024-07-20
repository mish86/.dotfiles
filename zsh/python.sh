#!/bin/bash

# python
export PATH="$(brew --prefix python)/libexec/bin:$PATH"

# pipx
# https://pipx.pypa.io/stable/
export PATH=".:$PATH:$HOME/.local/bin"
eval "$(register-python-argcomplete pipx)"
