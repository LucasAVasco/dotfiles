#!/bin/bash
#
# Install fonts required by Neogit 'kitty' graph style.

# source ~/.config/bash/libs/install/wget.sh
source "$MY_BASH_LIBS/install/wget.sh"

fonts_folder=~/.fonts/auto_installed

install_wget_init
install_wget_download https://raw.githubusercontent.com/rbong/flog-symbols/refs/heads/main/FlogSymbols.ttf FlogSymbols.ttf
install_wget_export_files "FlogSymbols.ttf" "$fonts_folder"
