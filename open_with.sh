#!/bin/bash

# --- #
# OSX #
# --- #

# map extensions to vscode
# https://stackoverflow.com/questions/43665346/can-somebody-explain-how-to-make-vscode-the-default-editor-on-osx/43665710#43665710
curl "https://raw.githubusercontent.com/github/linguist/master/lib/linguist/languages.yml" |
  yq -r "to_entries | (map(.value.extensions) | flatten) - [null] | unique | .[]" |
  xargs -L 1 -I "{}" duti -s com.microsoft.VSCode {} all
