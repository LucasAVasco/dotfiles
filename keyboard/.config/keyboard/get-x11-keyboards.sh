#!/bin/bash
#
# Outputs all keyboards available to the Xorg session. Each line is a keyboard device.

source ~/.local/lib/dotfiles/bash/strict.sh

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

source ./lib/x11_keyboards.sh

# Removes the keyboard ID (number after the '\t')
x11_keyboards_get | sed 's/\t.*//g'
