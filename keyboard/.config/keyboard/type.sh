#!/bin/bash
#
# Auto-type text on the current focused (active) window.

source ~/.config/bash/libs/linux/keyboard/sound_emulator.sh
source ~/.config/bash/libs/linux/session.sh
source ~/.config/bash/libs/help.sh

help() {
	help_msg_format '\t' << EOF
	DESCRIPTION

	Auto-type text on the current focused (active) window.

	USAGE

	type.sh [options] <text-to-auto-type...>

	OPTIONS
		--notify-end
			Show a notification after the text by typed.

		-h | --help
			Show this message and exits.

	ARGUMENTS
		text-to-auto-type
			Auto-type all arguments after the options
EOF
}

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

		-h | --help)
			help
			exit
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
