#!/bin/bash


# Only runs this script if the user is allowed to install external software
[[ "$ALLOW_EXTERNAL_SOFTWARE" != "y" ]] && return

# ASDF and its completions (only if not already sourced from the '~/.profile' file)
export PATH="$HOME/.asdf/shims:$PATH"

# Conda startup command
MINICONDA_INSTALL_DIR=~/.miniconda3
alias conda-init='eval "$('$MINICONDA_INSTALL_DIR'/bin/conda shell.bash hook)"'
