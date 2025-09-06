#!/bin/bash
#
# Clear the user clipboard. This is a internal script used by the './__clear.sh' script. Do not use it directly.

# Xorg session
if [[ -z "$WAYLAND_DISPLAY" ]]; then
	echo -n '' | xclip -i -sel primary
	echo -n '' | xclip -i -sel secondary
	echo -n '' | xclip -i -sel clipboard

# Wayland session
else
	wl-copy --clear
	wl-copy --primary --clear
fi
