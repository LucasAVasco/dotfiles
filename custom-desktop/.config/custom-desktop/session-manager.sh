#!/bin/bash
#
# Open the session manager.

if [[ "$CUSTOM_DESKTOP_USE_QUICKSHELL" == y ]]; then
	exec ~/.config/quickshell/manager.sh run sessions
else
	exec ~/.config/rofi/tools/session_manager.sh
fi
