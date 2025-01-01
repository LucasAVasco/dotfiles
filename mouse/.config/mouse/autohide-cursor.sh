#!/bin/bash
#
# Automatically hide the mouse cursor if it is not being used.
#
# Dependencies:
#
# * Bash
# * unclutter
# * My `pkill-wait` script


# Xorg configuration
if [[ -z "$WAYLAND_DISPLAY" ]]; then
	pkill-wait -u "$USER" unclutter

	# The '--ignore-buttons 4,5,6,7' flag makes `unclutter` ignore vertical and horizontal scroll
	unclutter --fork --hide-on-touch --start-hidden --ignore-buttons '4,5,6,7' --timeout 3

	# Wayland configuration
else
	echo "[$0] Error: This tool does not work in Wayland"
fi
