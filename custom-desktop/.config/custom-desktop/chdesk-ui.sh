#!/bin/bash
#
# Open the custom 'chdesk' user interface.

if [[ "$CUSTOM_DESKTOP_USE_QUICKSHELL" == y ]]; then
	exec ~/.config/quickshell/manager.sh run chdesk-ui
else
	exec ~/.config/rofi/tools/chdesk.sh
fi
