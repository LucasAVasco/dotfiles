#!/bin/bash

source ../../../.lib/strict.sh

source ../../../.lib/code_block.sh

test -f ~/.zshrc && code_block_remove ~/.zshrc

exit 0
