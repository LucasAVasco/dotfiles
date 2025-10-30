#!/bin/bash
#
# Configuration of the fallback installers

[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && exit

cd ~/.local/dotfiles_bin_fallback/
./setup.sh
