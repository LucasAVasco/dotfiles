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
	echo -n '' | xclip -i -sel primary
	echo -n '' | xclip -i -sel secondary
	echo -n '' | xclip -i -sel clipboard

# Wayland session
else
	wl-copy --clear
	wl-copy --primary --clear
fi

# Shows a notification at the end
if [[ $show_notification == y ]]; then
	notify-send 'Clipboard cleared' "Cleared at $(date '+%Hh %Mmin %Ss')"
fi
