#!/bin/bash
#
# Copy the provided arguments or standard input to the clipboard. Works in Xorg and Wayland.
#
# Dependencies:
# - xclip (Xorg)
# - wl-copy (Wayland)

source ~/.config/bash/libs/help.sh

help() {
	help_msg_format '\t\t' << EOF
		Copy the provided arguments or standard input to the clipboard. Works in Xorg and Wayland.

		USAGE
		copy.sh [options] -- <content to copy>

		OPTIONS
			--stdin
				copy the standard input to the clipboard.

			-t | --xorg_target
				Sets the Xorg target of the copied content.

		EXAMPLES
			copy.sh arg1 arg2
				Copy 'arg1 arg2' to the clipboard.

			copy.sh -- --arg1 --arg2
				Copy '--arg1 --arg2' to the clipboard.

			copy.sh
				Copy the standard input to the clipboard.

			copy.sh --stdin
				Copy the standard input to the clipboard.

			copy.sh --stdin --xorg_target image/png
				Copy an image provided from the standard input to the clipboard (Xorg requires a \`target\`).
EOF
}

if [[ "$1" == '-h' || "$1" == '--help' ]]; then
	help
	exit 0
fi

# Parses the arguments
copy_stdin='n'
xorg_target=()
clear_after=''

while [[ $# -gt 0 ]]; do
	case "$1" in
		--stdin )
			copy_stdin='y'
			;;

		-t | --xorg_target )
			xorg_target=(-t "$2")
			shift
			;;

		-c | --clear )
			clear_after="$2"
			shift
			;;

		-- )
			shift
			break
			;;

		*)
			break
			;;
	esac

	shift
done

# If there are not a content to copy from the command line arguments, fallback to copy the standard input
if [[ $# == 0 ]]; then
	copy_stdin='y'
fi

# Xorg session
if [[ -z "$WAYLAND_DISPLAY" ]]; then
	if [[ "$copy_stdin" == 'y' ]]; then
		xclip -selection clipboard ${xorg_target[@]}
	else
		args="${@}"  # Convert to string separated by spaces

		# Must print with `printf` because `echo` may interpret '-e', '-n', and '-E'
		printf "%s" "$args" | xclip -selection clipboard ${xorg_target[@]}
	fi

# Wayland session
else
	if [[ "$copy_stdin" == 'y' ]]; then
		wl-copy
	else
		wl-copy -- "$@"
	fi
fi

# Clears the clipboard
if [[ -n "$clear_after" ]]; then
	current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
	"$current_dir/clear.sh" --async "$clear_after"
fi
