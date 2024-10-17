#!/bin/bash
#
# Wrapper to the scripts that effectively manage the keyboard sound emulator


current_dir=$(realpath -m -- "$0/../")


# Xorg configuration
if [[ -z "$WAYLAND_DISPLAY" ]]; then
	"$current_dir/bucklespring.sh" "$@"

# Wayland configuration
else
	echo 'to do'
fi
