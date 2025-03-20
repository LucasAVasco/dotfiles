#!/bin/bash
#
# Clear the user clipboard

# Parses the arguments
show_notification=y
if [[ "$1" == '--no-notify' ]]; then
	show_notification=n
	shift
fi

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

# Shows a notification at the end
if [[ $show_notification == y ]]; then
	notify-send 'Clipboard cleared' "Cleared at $(date '+%Hh %Mmin %Ss')"
fi
