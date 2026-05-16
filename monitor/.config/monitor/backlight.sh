#!/bin/bash
#
# Manage monitor back light

set -e

source ~/.local/lib/dotfiles/bash/help.sh

help_handle y "$@" <<EOF
	Manage backlight

	Usage:
		backlight [command] [arguments]

	Commands:
		get   Get the current backlight value
		set   Set the current backlight value
EOF

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

if [[ "$1" == "get" ]]; then
	shift
	./get_backlight.lua "$@"
elif [[ "$1" == "set" ]]; then
	shift
	./set_backlight.lua "$@"
else
	echo "Unknown command: $1" >&2
	exit 1
fi
