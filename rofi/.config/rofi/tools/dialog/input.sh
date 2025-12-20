#!/bin/bash
#
# Ask a user input with Rofi.
#
# $1: question to ask the user.
#
# Return the user's input. If the user aborts, this script exits with code 1.

set -e

question="$1"

response=$(echo '' | rofi -theme ~/.config/rofi/tools/dialog/themes/input.rasi -p "$question" -dmenu -i) || exit 1

printf '%s' "$response"
