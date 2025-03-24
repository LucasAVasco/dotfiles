#!/bin/bash
#
# Paste the clipboard to standard output or file.

set -e

source ~/.config/bash/libs/linux/session.sh
source ~/.config/bash/libs/help.sh

help() {
	help_msg_format '\t' << EOF
	paste.sh [options]

	OPTIONS
		-t | --type <clipboard-type>
			Sets the clipboard type. Example 'text/plain'.
			The target depends of the backend: 'xclip' on Xorg or 'wl-paste' on Wayland. You can see the available types with 'paste.sh -t'.

		--ask-type
			Interactively select the clipboard type.

		-o | --output-file <output-file>
			Save the clipboard content in this file instead of print to clipboard.

		--ask-out-file
			Interactively select the output file.

		-h | --help
			Show this message
EOF
}

session_type=$(linux_session_get_type)

error_unknown_session_type=1

# $1: received session type
exit_error_unknown_session_type() {
	echo "Unknown session type: '$1'" >&2
	exit $error_unknown_session_type
}

# Show the available clipboards types. On Xorg, show `xclip` targets.
show_clipboard_types() {
	case "$session_type" in
		xorg)
			xclip -selection clipboard -target TARGETS -out | sed '/TARGETS/d'
			;;

		wayland)
			wl-paste --list-types
			;;

		*)
			exit_error_unknown_session_type "$session_type"
			;;
	esac
}

# Command arguments
show_help=n

clipboard_type=''
ask_clipboard_type=n
set_clipboard_type=n

output_file=''
ask_file=n
output_to_file=n

while [[ "$#" -gt 0 ]]; do
	case "$1" in
		-t | --type)
			clipboard_type="$2"
			set_clipboard_type=y
			if [[ -n "$clipboard_type" ]]; then
				shift
			fi
			;;

		--ask-type )
			ask_clipboard_type=y
			set_clipboard_type=y
			;;

		-o | --output-file )
			output_file="$2"
			output_to_file=y
			shift
			;;

		--ask-out-file )
			ask_file=y
			output_to_file=y
			;;

		-h | --help )
			show_help=y
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

# Shows help message
if [[ "$show_help" == y ]]; then
	help
	exit
fi

# Shows the available clipboard type
if [[ $set_clipboard_type == y && $ask_clipboard_type == n && "$clipboard_type" == '' ]]; then
	show_clipboard_types
	exit
fi

# Interactively selects a clipboard type
if [[ $set_clipboard_type == y && $ask_clipboard_type == y && "$clipboard_type" == '' ]]; then
	fzf_header='Format to save the clipboard data:'

	targets=$(show_clipboard_types)

	if (( $(echo "$targets" | wc -l) == 1 )); then
		# Automatically selects the only available target
		clipboard_type="$targets"
	else
		clipboard_type=$(echo -n "$targets" | fzf --header="$fzf_header")
	fi
fi

# Generates the clipboard type option
if [[ -n "$clipboard_type" ]]; then
	case $session_type in
		xorg)
			clipboard_type_option="-target $clipboard_type"
			;;

		wayland)
			clipboard_type_option="--type $clipboard_type"
			;;

		*)
			exit_error_unknown_session_type "$session_type"
			;;
	esac
fi

# Interactively selects the file to paste
if [[ -z "$output_file" && $ask_file == y ]]; then
	tput clear
	echo -n 'Insert the file path to paste the clipboard into: '
	read output_file
fi

# Pastes the content
case "$session_type" in
	xorg)
		if [[ $output_to_file == y ]]; then
			xclip -selection clipboard $clipboard_type_option -out > "$output_file"
		else
			xclip -selection clipboard $clipboard_type_option -out
		fi
		;;

	wayland)
		if [[ $output_to_file == y ]]; then
			wl-paste $clipboard_type_option > "$output_file"
		else
			wl-paste $clipboard_type_option
		fi
		;;

	*)
		exit_error_unknown_session_type "$session_type"
		;;
esac
