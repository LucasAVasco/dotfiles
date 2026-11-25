#!/bin/bash

source ~/.local/lib/dotfiles/bash/strict.sh

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

source ./lib/x11_keyboards.sh

# Load all keyboard in a array. Each line is a keyboard device and its ID (separated by '\t')
readarray -t lines < <(x11_keyboards_get)

# Maps the keyboard name to its numerical ID
declare -A keyboard_to_device_id=()
for line in "${lines[@]}"; do
	keyboard="${line%$'\t'*}"
	device_id="${line#*$'\t'}"

	keyboard_to_device_id["$keyboard"]="$device_id"
done

# Reset all keyboard layouts
for device_id in "${keyboard_to_device_id[@]}"; do
	setxkbmap -device "$device_id" -layout "${XKB_DEFAULT_LAYOUT:-us}"
done

# Reads the keyboard file and updates the layouts of the keyboards
KEYBOARD_LAYOUT_FILE=~/.local/state/custom-desktop/keyboard-layouts
readarray -t lines < "$KEYBOARD_LAYOUT_FILE"
for line in "${lines[@]}"; do
	keyboard="${line%$'\t'*}"
	layout="${line#*$'\t'}"
	device_id="${keyboard_to_device_id["$keyboard"]:-}"

	# Updates the layout
	if [[ -n "${device_id}" ]]; then
		setxkbmap -device "$device_id" -layout "$layout"
	fi
done
