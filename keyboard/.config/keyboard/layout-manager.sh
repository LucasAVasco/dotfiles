#!/bin/bash
#
# Manage keyboard layouts

source ~/.local/lib/dotfiles/bash/strict.sh

source ~/.local/lib/dotfiles/bash/help.sh
source ~/.local/lib/dotfiles/bash/linux/session.sh

help_handle y "$@" <<EOF
	Manage per-keyboard X11 keymap layouts.

	Usage:
		$(basename "$0") <command> [arguments]

	Commands:
		set-layout [keyboard] [layout]   Assign a layout to a keyboard. Prompts via fzf if either argument is omitted.
		rm-layout  [keyboard]            Remove the saved layout for a keyboard. Prompts via fzf if omitted.
		get-layout [keyboard]            Print the saved layout for a keyboard. Prompts via fzf if omitted.
		list                             Print all saved keyboard-to-layout mappings.

	Environment Variables:
		CUSTOM_DESKTOP_GET_KEYBOARDS_NAMES_COMMAND
			Command run to list available keyboard names (one per line) when
			<keyboard> is not provided as an argument.

		CUSTOM_DESKTOP_ON_KEYBOARDS_UDPATED_COMMAND
			Optional hook executed as '<command> <keyboard> <layout>' whenever a
			layout is set or removed (layout is empty on removal).

	Files:
		~/.local/state/custom-desktop/keyboard-layouts
			Tab-separated storage mapping keyboard names to layouts.

	Examples:
		$(basename "$0") set-layout "AT Translated Set 2 keyboard" us
		$(basename "$0") set-layout
		$(basename "$0") get-layout "AT Translated Set 2 keyboard"
		$(basename "$0") rm-layout
		$(basename "$0") list
EOF

# Validation
if (( "$#" < 1 )); then
	echo "Main command not provided" >&2
	exit 1
fi

# Default environment variables for X11
if [[ $(linux_session_get_type) == x11 ]]; then
	if [[ -z "${CUSTOM_DESKTOP_GET_KEYBOARDS_NAMES_COMMAND:-}" ]]; then
		CUSTOM_DESKTOP_GET_KEYBOARDS_NAMES_COMMAND=~/.config/keyboard/get-x11-keyboards.sh
	fi
	if [[ -z "${CUSTOM_DESKTOP_ON_KEYBOARDS_UDPATED_COMMAND:-}" ]]; then
		CUSTOM_DESKTOP_ON_KEYBOARDS_UDPATED_COMMAND=~/.config/keyboard/update-x11-keyboards.sh
	fi
fi

# Run all commands relative to the current directory
current_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
cd "$current_dir"

# Create keyboard layout file
KEYBOARD_LAYOUT_FILE=~/.local/state/custom-desktop/keyboard-layouts
mkdir -p "$(dirname "$KEYBOARD_LAYOUT_FILE")"
touch "$KEYBOARD_LAYOUT_FILE"

# Main command
main_command="$1"
shift

# Prompt user to select a keyboard if not provided
#
# $1: optional keyboard name
# $2: fzf header prompt
select_keyboard() {
	local keyboard="${1:-}"
	local header="${2:-Select keyboard}"

	if [[ -z "$keyboard" ]]; then
		if [[ -z "${CUSTOM_DESKTOP_GET_KEYBOARDS_NAMES_COMMAND:-}" ]]; then
			echo "The CUSTOM_DESKTOP_GET_KEYBOARDS_NAMES_COMMAND environment variable must be set if the keyboard is not provided" >&2
			exit 1
		fi
		keyboard=$(bash -c "$CUSTOM_DESKTOP_GET_KEYBOARDS_NAMES_COMMAND" | fzf --header="$header")
	fi

	printf "%s" "$keyboard"
}

# Remove a keyboard entry from the configuration file.
#
# $1: name of the keyboard to remove.
remove_keyboard_from_file() {
	local keyboard="$1"
	[[ -z "$keyboard" ]] && return 0
	KEYBOARD="$keyboard" perl -i -ne 'print unless index($_, $ENV{KEYBOARD} . "\t") == 0' "$KEYBOARD_LAYOUT_FILE"
}

# Get the layout for a given keyboard from the configuration file.
#
# $1: name of the keyboard to look up.
get_keyboard_layout() {
	local keyboard="$1"
	KEYBOARD="$keyboard" perl -ne '
		my $prefix = $ENV{KEYBOARD} . "\t";
		if (index($_, $prefix) == 0) {
			print substr($_, length($prefix));
			$found = 1;
			last;
		}
		END { exit($found ? 0 : 1); }
	' "$KEYBOARD_LAYOUT_FILE"
}

# Calls the callback registered to be called when the layout of a keyboard changed
call_on_keyboard_change_callback() {
	local keyboard="$1"
	local layout="${2:-}"
	if [[ -n "${CUSTOM_DESKTOP_ON_KEYBOARDS_UDPATED_COMMAND:-}" ]]; then
		bash -c "$CUSTOM_DESKTOP_ON_KEYBOARDS_UDPATED_COMMAND \"\$1\" \"\$2\"" _ "$keyboard" "$layout"
	fi
}

case "$main_command" in
	set-layout)
		keyboard=$(select_keyboard "${1:-}" "Select keyboard to set layout")

		layout="${2:-}"
		if [[ -z "$layout" ]]; then
			layout=$(localectl list-x11-keymap-layouts | fzf --header='Select the keyboard layout')
		fi

		# Remove the layout from the file if it exists
		remove_keyboard_from_file "$keyboard"

		# Append the layout to the file
		printf "%s\t%s\n" "$keyboard" "$layout" >> "$KEYBOARD_LAYOUT_FILE"

		# Callback called when the keyboard file updates
		call_on_keyboard_change_callback "$keyboard" "$layout"
		;;

	rm-layout)
		keyboard=$(select_keyboard "${1:-}" "Select keyboard to remove layout")
		remove_keyboard_from_file "$keyboard"
		call_on_keyboard_change_callback "$keyboard" ""
		;;

	get-layout)
		keyboard=$(select_keyboard "${1:-}" "Select keyboard to get layout")
		if ! get_keyboard_layout "$keyboard"; then
			echo "No layout configured for keyboard: $keyboard" >&2
			exit 1
		fi
		;;

	list)
		cat "$KEYBOARD_LAYOUT_FILE"
		;;

	*)
		echo "Unknown command: $main_command" >&2
		exit 1
		;;
esac
