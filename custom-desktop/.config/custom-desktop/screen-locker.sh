#!/bin/bash
#
# Start/restart the screen locker.

source ~/.local/lib/dotfiles/bash/strict.sh

if [[ "$(~/.config/screenlocker/manager.sh is-active)" == y ]]; then
	~/.config/screenlocker/manager.sh disable --no-notify
fi

~/.config/screenlocker/manager.sh enable --no-notify
