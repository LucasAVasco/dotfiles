#!/bin/bash
#
# Auto-type text on the current focused (active) window.

set -e

source ~/.local/lib/dotfiles/bash/linux/keyboard/sound_emulator.sh
source ~/.local/lib/dotfiles/bash/linux/session.sh
source ~/.local/lib/dotfiles/bash/help.sh

help_handle y "$@" << EOF
	Auto-type text on the current focused (active) window.

	Usage:
		type.sh [options] <text-to-auto-type...>

	Flags:
		--notify-end
			Show a notification after the text by typed.

	Arguments:
		<text-to-auto-type>    Auto-type all arguments after the options
EOF

# Arguments passed to the command
notify_end=n
while [[ "$#" -gt 0 ]]; do
	case "$1" in
		--)
			shift
			break
			;;

		--notify-end)
			notify_end=y
			;;

		*)
			break
			;;
	esac

	shift
done

linux_keyboard_sound_emulator_disable_until_end

session_type=$(linux_session_get_type)

case "$session_type" in
	'xorg')
		xdotool type -- "$@"
		;;
	'wayland')
		wtype -- "$@"
		;;

	*)
		echo "Unsupported session type: '$session_type'"
		exit 1
		;;
esac

if [[ "$notify_end" == y ]]; then
	notify-send 'Auto type' "End auto type at $(date '+%Hh %Mmin %Ss')"
fi
