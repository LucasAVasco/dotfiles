#!/bin/bash
#
# Module to manage binaries (executable files).

source ~/.config/bash/libs/string.sh

# Returns the executable path.
#
# $1: Executable name or path.
#
# Return the executable path or empty string if not found.
bin_get_executable_path() {
	local executable="$1"
	local executable_path=$(type "$executable" || echo '') # Returns something like 'bash is /usr/bin/bash'
	executable_path="${executable_path#* is }" # Removes text until 'is '

	echo "$executable_path"
}

# Checks if the executable is inside a directory.
#
# $1: Executable name or path.
# $2: Directory path.
#
# Returns 'y' or 'n'.
bin_executable_is_inside_dir() {
	local executable="$1"
	local dir="$2"

	local path=$(bin_get_executable_path "$executable")

	if [[ -z "$path" ]]; then
		echo n
		return 0
	fi

	string_has_substring "$path" "$dir"
}

# Checks if the executable is inside a directory using regex.
#
# $1: Executable name or path.
# $2: Directory regex (Bash regex).
#
# Returns 'y' or 'n'.
bin_executable_is_inside_dir_regex() {
	local executable="$1"
	local dir="$2"

	local path=$(bin_get_executable_path "$executable")

	if [[ -z "$path" ]]; then
		echo n
		return 0
	fi

	string_has_regex "$path" "$dir"
}
