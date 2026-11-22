#!/bin/bash
#
# Open the application launcher.

if [[ "$CUSTOM_DESKTOP_USE_QUICKSHELL" == y ]]; then
	exec ~/.config/quickshell/manager.sh run launcher
else
	exec ~/.config/rofi/tools/applications.sh
fi
