#!/bin/bash
#
# Move the scroll wheel.

set -e

source ~/.local/lib/dotfiles/bash/help.sh

help_handle y "$@" << EOF
	Move the scroll wheel

	Usage:
		Scroll.sh <num-scrolls>

	Arguments:
		<num-scrolls> The number of times to scroll. A positive number moves the wheel up, a negative number moves the wheel down and
			zero executes a click.
EOF

# Simulate the scroll wheel.
#
# $1: Number of times to scroll. A positive number scrolls up, a negative number scrolls down and zero executes a click.
xorg_implementation() {
	local times="$1"
	local click="4"

	# Click
	if [[ "$times" == 0 ]]; then
		xte "mouseclick 2"
		return
	fi

	# Scroll down
	if [[ "$times" -lt 0 ]]; then
		click="5"
		times="$(( -1 * times ))"
	fi

	# Send the scroll wheel clicks to Xorg server
	for i in $(seq 1 "$times"); do
		sleep 0.01
		xte "mouseclick $click"
	done
}

# Main
if [[ -z "$WAYLAND_DISPLAY" ]]; then # Xorg
	xorg_implementation "$@"
else # Wayland
	echo "[$0] Error: This tool does not work in Wayland"
fi
