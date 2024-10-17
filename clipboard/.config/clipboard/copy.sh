#!/bin/bash
#
# Copy the provided arguments to the clipboard


# Xorg session
if [[ -z "$WAYLAND_DISPLAY" ]]; then
	echo -n "$@" | xclip -selection clipboard

# Wayland session
else
	wl-copy "$@"
fi
