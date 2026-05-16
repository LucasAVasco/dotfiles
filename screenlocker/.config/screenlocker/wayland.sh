#!/bin/bash
#
# Wayland screen locker management script

set -e

source ~/.local/lib/dotfiles/bash/help.sh

help_handle y "$@" << EOF
	Wayland screen locker management script.

	Usage:
		wayland.sh <command> [flags...]

	Commands:
		enable
			Automatically run the screen-locker after a predefined time interval

		disable
			Disable the automatic screen-locker

		toggle
			Toggle the automatic screen-locker

		run
			Lock the screen

		is-enabled
			Check if the screen locker is enabled. Returns 'y' if it is enabled, 'n' otherwise

	Flags:
		--no-notify   does not triggers a desktop notification after the operation
EOF

if [[ -z "$WAYLAND_DISPLAY" ]]; then
	echo "$log_prefix Wrong Backend. This scripts only works with Wayland, but you are using Wayland"
	exit 1
fi

current_dir=$(realpath -m -- "${BASH_SOURCE[0]}/../")
log_prefix='[screenlocker/wayland.sh]'

# First argument is the command
command="$1"
shift

# Enable the screen locker idle.
enable_screen_locker() {
	pkill-wait -u "$USER" hypridle 2> /dev/null || true
	nohup hypridle run > /dev/null 2>&1 &

	if [[ "$1" != '--no-notify' ]]; then
		notify-send 'Screen Locker' 'Enabled'
	fi
}

# Disable the screen locker idle.
disable_screen_locker() {
	pkill-wait -u "$USER" hypridle 2> /dev/null || true

	if [[ "$1" != '--no-notify' ]]; then
		notify-send 'Screen Locker' 'Disabled'
	fi
}

# Check if the screen locker is enabled.
#
# Returns 'y' if it is enabled, 'n' otherwise.
screen_locker_is_enabled() {
	pgrep -u "$USER" hypridle > /dev/null 2>&1 && echo 'y' || echo 'n'
}

# Lock the screen. This is not a blocking function.
run() {
	~/.config/quickshell/manager.sh run lock
}

case "$command" in
	enable)
		enable_screen_locker "$@"
		;;

	disable)
		disable_screen_locker "$@"
		;;

	toggle)
		[[ "$(screen_locker_is_enabled)" == y ]] && disable_screen_locker "$@" || enable_screen_locker "$@"
		;;

	run)
		run
		;;

	is-enabled)
		screen_locker_is_enabled
		;;

	*)
		echo "$log_prefix Unknown option. $1"
		exit 1
		;;
esac
