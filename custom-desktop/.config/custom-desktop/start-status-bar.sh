#!/bin/bash
#
# Start the status bar.

source ~/.local/lib/dotfiles/bash/strict.sh

if [[ "$(~/.config/quickshell/manager.sh is-active)" == y ]]; then
	exec ~/.config/quickshell/manager.sh restart
else
	exec ~/.config/quickshell/manager.sh start
fi
