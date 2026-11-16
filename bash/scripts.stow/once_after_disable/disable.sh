#!/bin/bash

source ../../../.lib/strict.sh

source ../../../.lib/code_block.sh

test -f ~/.bash_profile && code_block_remove ~/.bash_profile
test -f ~/.bashrc && code_block_remove ~/.bashrc

exit 0
