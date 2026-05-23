#!/bin/bash
#
# Utilities related to Linux sessions.

# Return the current session type.
#
# Returns: 'xorg', 'wayland', 'tty' or '' (if can not be determined).
linux_session_get_type() {
	if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
		echo -n 'wayland'
	elif [[ -n "${DISPLAY:-}" ]]; then
		echo -n 'xorg'
	else
		echo -n "${XDG_SESSION_TYPE:-}"
	fi
}
