#!/bin/bash
#
# Execute the screen locker configured to the current session


current_dir=$(realpath -m -- "$0/../")


# Xorg configuration
if [[ -z "$WAYLAND_DISPLAY" ]]; then
	pgrep xsecurelock || "$current_dir/xsecurelock.sh"

# Wayland configuration
else
	echo 'to do'
fi
