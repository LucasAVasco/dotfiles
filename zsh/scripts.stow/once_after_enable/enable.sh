#!/bin/bash

source ../../../.lib/strict.sh

source ../../../.lib/code_block.sh

touch ~/.zshrc
code_block_add_source ~/.zshrc '~/.config/zsh/main.zsh'
