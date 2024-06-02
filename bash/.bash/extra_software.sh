#!/bin/bash


# ASDF and its completions
test -f ~/.asdf/asdf.sh && source ~/.asdf/asdf.sh
test -f ~/.asdf/completions/asdf.bash && source ~/.asdf/completions/asdf.bash


# Conda startup command
MINICONDA_INSTALL_DIR=~/.miniconda3
alias conda-init='eval "$('$MINICONDA_INSTALL_DIR'/bin/conda shell.bash hook)"'
