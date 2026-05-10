#!/bin/bash
#
# Utilities for working with file/directory paths

# Expand the tilde in a path.
#
# The tilde must be the first character in the string. Only expand the first tilde.
#
# $1: file path.
# Return the path with the tilde expanded.
paths_expand_tilde() {
	local file_path="$1"

	# Manually expands the '~' prefix to the user home
	if [[ "${file_path:0:1}" == '~' ]]; then
		file_path="$HOME/${file_path:2}"
	fi

	echo -n "$file_path"
}

# Replace the home in a path by another user home.
#
# $1: new user.
# $2: absolute path of the file (you must manually expand the tilde).
# Return the path with other user home.
paths_replace_user_home() {
	local new_user="$1"
	local src_file="$2"

	echo -n "$src_file" | sed 's/\/home\/[a-zA-Z0-9_-]*/\/home\/'"$new_user"/
}

# Ensure the provided path has a trailing slash.
#
# $1: path.
# Return the path with trailing slash.
paths_ensure_trailing_slash() {
	local src="$1/"
	src="${src/%\/\//\/}"

	echo "$src"
}

# Ensure the provided path has a trailing slash if it is a directory.
#
# $1: path.
# Return the path with trailing slash (if it is a directory).
paths_ensure_trailing_slash_on_directories() {
	local src="$1"

	if [[ -d "$src" ]]; then
		paths_ensure_trailing_slash "$src"
	else
		echo "$src"
	fi
}

# Check if the provided path is a directory.
#
# $1: path.
#
# Return 'y' or 'n'.
paths_is_directory() {
	local src="$1"

	# Current folder
	if [[ "$src" == . || "$src" == */. ]]; then
		echo -n y
		return
	fi

	# Parent folder
	if [[ "$src" == .. || "$src" == */.. ]]; then
		echo -n y
		return
	fi

	# Any other folder
	if [[ "$src" == */ ]]; then
		echo -n y
		return
	fi

	# Any other file
	echo -n n
}

# Check if the provided path is absolute.
#
# $1: path.
paths_is_abs() {
	if [[ "$1" == /* ]]; then
		echo -n y
	else
		echo -n n
	fi
}

# Get the top directory of a path
#
# $1: path
# $2: number of directories to go up. Default: 1
paths_get_top_dir() {
	local path="$1"
	local num="${2-1}"

	while [[ "$num" -gt 0 ]]; do
		path="$(dirname "$path")"
		num=$((num - 1))
	done

	printf "%s" "$path"
}
