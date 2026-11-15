#!/bin/bash

source ../../../.lib/strict.sh

source ../../../.lib/code_block.sh

test -f ~/.profile && code_block_remove ~/.profile

exit 0
