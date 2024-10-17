#!/bin/bash
#
# Script to clear the user clipboard


# Clears the clipboard in a Xorg session
if [[ -z "$WAYLAND_DISPLAY" ]]; then
	echo '' | xclip -i -sel primary
	echo '' | xclip -i -sel secondary
	echo '' | xclip -i -sel clipboard

# Clears the clipboard in a Wayland session
else
	wl-copy --clear
	wl-copy --primary --clear
fi
