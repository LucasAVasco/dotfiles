#!/bin/bash
#
# Screen locker management script
#
# Use `./manager.sh help` for further information
#
# Dependencies:
# - My './xorg.sh' script (Xorg backend)


current_dir=$(realpath -m -- "${BASH_SOURCE[0]}/../")
log_prefix='[screenlocker/manager.sh]'


# Xorg configuration
if [[ -z "$WAYLAND_DISPLAY" ]]; then
	exec "$current_dir/xorg.sh" "$@"
else
	exec "$current_dir/wayland.sh" "$@"
fi
