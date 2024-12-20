#!/bin/bash
#
# Xorg screen locker management script
#
# Use `./xorg.sh help` for further information


current_dir=$(realpath -m -- "${BASH_SOURCE[0]}/../")
log_prefix='[screenlocker/xorg.sh]'

# First argument is the command
command="$1"
shift


if [[ -n "$WAYLAND_DISPLAY" ]]; then
	echo "$log_prefix Wrong Backend. This scripts onluy works with Xorg, but you are using Wayland"
	exit 1
fi

show_help() {
	cat << EOF
Usage:
	this-script.sh Command [options...]

Commands:
	enable: Automatically run the screen-locker after a predefined time interval
	disable: Disable the automatic screen-locker
	disable: Toggle the automatic screen-locker
	run: Lock the screen

Options:
	--no-notify: does not triggers a desktop notification after the operation
EOF
}

enable_screen_locker() {
	pkill -u "$UID" xss-lock 2> /dev/null
	nohup xss-lock -- "$current_dir/xorg.sh" run > /dev/null 2>&1 &

	xset s on
	xset s blank
	xset +dpms

	if [[ "$1" != '--no-notify' ]]; then
		notify-send 'Screen Locker' 'Enabled'
	fi
}

disable_screen_locker() {
	pkill -u "$UID" xss-lock 2> /dev/null

	xset s off
	xset s noblank
	xset -dpms

	if [[ "$1" != '--no-notify' ]]; then
		notify-send 'Screen Locker' 'Disabled'
	fi
}

screen_locker_is_enabled() {
	pgrep xss-lock > /dev/null 2>&1 && echo 'y' || echo 'n'
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
		"$current_dir/xsecurelock.sh"
		;;

	is-enabled)
		screen_locker_is_enabled
		;;

	help | --help)
		show_help
		;;
	*)
		echo "$log_prefix Unknown option. $1"
		show_help
		;;
esac
