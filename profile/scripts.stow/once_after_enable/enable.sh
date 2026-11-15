#!/bin/bash

source ../../../.lib/strict.sh

source ../../../.lib/code_block.sh

touch ~/.profile
code_block_add_source ~/.profile '~/.config/profile/init.sh'
