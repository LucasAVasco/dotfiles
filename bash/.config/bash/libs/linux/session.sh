#!/bin/bash
#
# Utilities related to Linux sessions.

# Return the current session type.
#
# Returns: 'xorg' or 'wayland'
linux_session_get_type() {
	if [[ -z "$WAYLAND_DISPLAY" ]]; then
		echo 'xorg'
	else
		echo 'wayland'
	fi
}
