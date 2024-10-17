#!/bin/bash
#
# Clear the user clipboard


# Xorg session
if [[ -z "$WAYLAND_DISPLAY" ]]; then
	echo '' | xclip -i -sel primary
	echo '' | xclip -i -sel secondary
	echo '' | xclip -i -sel clipboard

# Wayland session
else
	wl-copy --clear
	wl-copy --primary --clear
fi
