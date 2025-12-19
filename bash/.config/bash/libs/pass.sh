#!/bin/bash
#
# Functions to interact with password manager (pass)

source ~/.config/bash/libs/linux/keyboard/sound_emulator.sh

_pass_password_dir=$(pass git rev-parse --show-toplevel || echo "$HOME/.password-store")

# Get the directory of the password files.
pass_get_password_dir() {
	echo -n "$_pass_password_dir"
}

# Get all password files.
#
# Return files separated by new lines.
pass_get_password_files() {
	cd "$_pass_password_dir"
	find * -type f -name '*.gpg'
	cd - > /dev/null
}

# Get all names of password files (without the extensions).
#
# Return file names separated by new lines.
pass_get_password_file_names() {
	pass_get_password_files | sed 's/^.\///g' | sed 's/.gpg$//g'
}

# Get the content of a password (text returned by `pass show <password_name>`).
#
# If the user fails in unlock the GPG key, the function will be aborted and return 1.
#
# The Keyboard sound emulator will be disabled until the function ends.
#
# $1: password file name (file without extension).
#
# Return the password content.
pass_get_password_content() {
	local keyboard_sound_emulator_active=$(linux_keyboard_sound_emulator_call is-active)
	if [[ $keyboard_sound_emulator_active == y ]]; then
		linux_keyboard_sound_emulator_call stop
	fi

	# If the user can not open the GPG key, the show command will return an error. Should abort the function after restore the keyboard
	# sound emulator
	local error=n
	pass show "$1" || error=y

	if [[ $keyboard_sound_emulator_active == y ]]; then
		linux_keyboard_sound_emulator_call start
	fi

	if [[ $error == y ]]; then
		return 1
	fi
}

# Get the name of the entry (remove the values from the entries).
#
# $stdin: entry lines (each line has the format `entry_name: entry_value`).
#
# Return the entry names.
_pass_filter_entry_names() {
	cut -d: -f1
}

# Get the value of the entries (remove the names from the entries).
#
# $stdin: entry lines (entry_name: entry_value).
#
# Return the entry value
_pass_filter_entry_values() {
	sed 's/[^:]*: *//g'
}

# Password content {{{

# Get the main password from the password content.
#
# $1: password content.
#
# Return the main password of the password.
pass_password_content_get_main_password() {
	printf '%s' "$1" | head -1
}

# Get the entries (list) from the password content.
#
# $1: password content.
#
# Return the password's entries separated by new lines.
pass_password_content_get_entries_names() {
	# Deletes the first line (password) | get the entry names
	printf '%s' "$1" | sed -e '1d' | _pass_filter_entry_names
}

# Get the entry value from the password content.
#
# $1: password content.
# $2: entry name. If empty, the default password will be selected.
#
# Return the entry value.
pass_password_content_get_entry_value() {
	local password_content="$1"
	local password_entry="$2"

	if [[ "$password_entry" == '' ]]; then
		printf '%s' "$password_content" | head -1
	else
		printf '%s' "$password_content" | sed -e '1d' | grep "^$password_entry:" | _pass_filter_entry_values
	fi
}

# Get the entry name from the password content.
#
# $1: password content.
# $2: entry name. If empty, the default password will be selected.
#
# Return the line number of the entry (starts at 1).
pass_password_content_get_entry_index() {
	local password_content="$1"
	local password_entry="$2"

	if [[ "$password_entry" == '' ]]; then
		echo -n 1
	else
		# The `sed` command delete the first line (default password)
		# the `grep` command matches the pattern with the line number (example "2: entry_name: entry_value")
		# The `cut` command get only the line number
		local line_num=$(printf '%s' "$password_content" | sed -e '1d' | grep -n "^$password_entry:" | cut -d: -f1)

		# The line number is zero based, need to add 1
		echo -n $((line_num + 1))
	fi
}

# }}}

# Password entry {{{

# Get the entry line from the password content.
#
# $1: password content.
# $2: entry name.
#
# Return the entry line.
pass_password_content_get_entry_line() {
	printf '%s' "$1" | grep "^$2:"
}

# Get the entry value from the entry line.
#
# $1: entry lines (each line has the format `entry_value: entry_value`).
#
# Return the entry name.
pass_entry_line_get_entry_names() {
	printf '%s' "$1" | sed -e '1d' | _pass_filter_entry_names
}

# Get the entry value from the entry line.
#
# $1: entry lines (each line has the format `entry_value: entry_value`).
#
# Return the entry value.
pass_entry_line_get_entries_values() {
	printf '%s' "$1" | _pass_filter_entry_values
}

# }}}
