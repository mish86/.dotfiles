#!/usr/bin/env bash

# User-local PATH additions for portable tools installed without admin rights.
# On Git Bash, $HOME maps to %USERPROFILE%, $LOCALAPPDATA maps to %USERPROFILE%/AppData/Local/

# Maven (portable install)
export PATH="$PATH:$LOCALAPPDATA/Microsoft/WindowsApps/apache-maven-3.9.16/bin"
