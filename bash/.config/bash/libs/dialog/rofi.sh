#!/bin/bash
#
# Dialog library with Rofi as the default user interface.

# Ask a yes/no question.
#
# $1: The question to ask.
# $2: The default value ('y' or 'n').
#
# Return 'y' or 'n'.
dialog_rofi_ask_boolean() {
	local question="$1"
	local default="$2"

	local choice=$(echo -e "Yes\nNo" | rofi -dmenu -i -p "$message")

	if [[ "$choice" == "Yes" ]]; then
		echo -n "y"
	elif [[ "$choice" == "No" ]]; then
		echo -n "n"
	else
		echo -n "$default"
	fi
}

# Ask a question to the user.
#
# $1: The question to ask.
#
# Return the user response.
dialog_rofi_ask_input() {
	local question="$1"

	local response=$(rofi -dmenu -i -p "$question")

	printf '%s' "$response"
}
