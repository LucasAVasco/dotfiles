#!/bin/bash
#
# Ask a confirmation with Rofi (yes/no).
#
# $1: question to ask the user.
# $2: default response. Returned if the user doesn't choose anything. May be any string, including 'y', 'n' and ''.
#
# Return the user's choice as a 'y', 'n' or the default

set -e

question="$1"
default="$2"

# List of options to choose
options='No\nYes'
if [[ "$default" == 'y' ]]; then
	options='Yes\nNo' # Try to place the default at the top
fi

# Get the user's choice
choice=$(echo -en "$options" | rofi -theme ~/.config/rofi/tools/dialog/themes/confirm.rasi -p "$question" -dmenu -i) || true

# Return the user's choice as a 'y', 'n' or the default
if [[ "$choice" == "Yes" ]]; then
	echo -n 'y'
elif [[ "$choice" == "No" ]]; then
	echo -n 'n'
else
	printf '%s' "$default"
fi
