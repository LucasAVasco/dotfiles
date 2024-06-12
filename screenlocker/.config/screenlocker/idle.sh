#!/bin/bash
#
# Configure the screen locker to automatically lock the screen after some time of inactivity


current_dir=$(realpath -m -- "$0/../")


# Xorg configuration
if [[ -z "$WAYLAND_DISPLAY" ]]; then
	pkill xss-lock 2> /dev/null
	xss-lock -- "$current_dir/run.sh" &

# Wayland configuration
else
	echo 'to do'

fi
