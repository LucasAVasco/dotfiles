#!/bin/bash
#
# Ask a selection with Rofi.
#
# $1: question to ask the user.
# $2..@: options.
#
# Return the user's choice or an empty string if the user aborts.

set -e

question="$1"
declare -a options=("${@:2}")

# Get the user's choice
for option in "${options[@]}"; do
	echo "$option";
done | rofi -theme ~/.config/rofi/tools/dialog/themes/select.rasi -p "$question" -dmenu -i || true
