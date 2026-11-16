#!/bin/bash

source ../../../.lib/strict.sh

source ../../../.lib/code_block.sh

touch ~/.bash_profile
code_block_add_source ~/.bash_profile '~/.config/bash/profile.sh'

touch ~/.bashrc
code_block_add_source ~/.bashrc '~/.config/bash/bashrc.sh'
