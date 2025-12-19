#!/bin/bash
#
# Menu to select a password from 'pass' and copy or auto type it.

set -e

source ~/.config/bash/libs/pass.sh
source ~/.config/bash/libs/linux/clipboard.sh
source ~/.config/bash/libs/linux/keyboard/auto-type.sh

main_password_entry_name='Main Password'

# Select some line with Rofi.
#
# $1: prompt
# $stdin: lines to select.
#
# Return the selected line.
select_with_rofi() {
	rofi -p "$1" -dmenu "$@"
}

# Select a password name with Rofi.
select_password_name_with_rofi() {
	pass_get_password_file_names | select_with_rofi 'Select a password'
}

# Select a entry from the password entries.
#
# If the user selects `$main_password_entry_name`, the function will return ''
#
# $1: password_entries.
#
# Return the selected entry or ''.
select_entry_with_rofi() {
	local password_entries="$1"
	local -i num_password_entries=$(echo "$password_entries" | wc -l)

	if (( "$num_password_entries" == 0 )); then
		echo "$password_entries"
	else
		local selected=$(echo -e "$main_password_entry_name\n$password_entries" | select_with_rofi 'Select an entry')
		if [[ "$selected" == "$main_password_entry_name" ]]; then
			echo ''
		else
			echo "$selected"
		fi
	fi
}

# Select a entry field (name, value or both) from the password content.
#
# $1: password content.
# $2: entry name.
#
# Return the text of the selected fields.
select_entry_field_with_rofi() {
	local password_content="$1"
	local entry_name="$2"

	local option=$(echo -e 'Entry name\nEntry value\nEntry name and value' | select_with_rofi 'Select an entry field')

	if [[ "$option" == 'Entry name' ]]; then
		printf "%s" "$entry_name"

	elif [[ "$option" == 'Entry value' ]]; then
		pass_password_content_get_entry_value "$password_content" "$entry_name"

	elif [[ "$option" == 'Entry name and value' ]]; then
		local entry_value=$(pass_password_content_get_entry_value "$password_content" "$entry_name")
		printf "%s\t%s" "$entry_name" "$entry_value"

	else
		echo "Unknown option selected by the user: '$usage'"
		exit 1
	fi
}

# Copy to clipboard or auto type the selected content (select the behavior with Rofi).
#
# $1: content to copy or type.
copy_or_type_text_with_rofi() {
	local content="$1"

	local option=$(echo -e 'Copy to clipboard\nAuto type' | select_with_rofi 'Select a behavior')

	if [[ "$option" == "Copy to clipboard" ]]; then
		linux_clipboard_copy --clear 10 -- "$content"

	elif [[ "$option" == 'Auto type' ]]; then
		linux_keyboard_auto_type --notify-end -- "$content"

	else
		echo "Unknown option selected by the user: '$usage'"
		exit 1
	fi
}

# Creates the password store if it doesn't exist
if [[ ! -d "$(pass_get_password_dir)" ]]; then
	~/.config/secrets/setup-pass.sh
fi

# Gets the password content
password_name=$(select_password_name_with_rofi)
password_content=$(pass_get_password_content "$password_name")

# Selects the entry
entries_names=$(pass_password_content_get_entries_names "$password_content")
selected_entry_name=$(select_entry_with_rofi "$entries_names")

field=""

if [[ "$selected_entry_name" == '' ]]; then # Selected main password
	field=$(pass_password_content_get_main_password "$password_content")

else # Selected a password entry
	field=$(select_entry_field_with_rofi "$password_content" "$selected_entry_name")
fi

copy_or_type_text_with_rofi "$field"
