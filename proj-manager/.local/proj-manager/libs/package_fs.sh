#!/bin/bash
#
# Library to manipulate the file system of a package provider and the invoke directory

source ~/.config/bash/libs/paths.sh

# Copies files from the current provider directory to the invoke directory.
#
# $1..n-1: The files to copy or `cp` arguments (relative to the provider directory). The '-i' option is added automatically
# $n: The target directory (relative to the invoke directory)
package_fs_cd() {
	local where="$PM_INVOKE_DIR/${@: -1}"

	# Executed inside a sub-shell so it doesn't change the current directory
	(
		cd "$PM_PROVIDER_DIR" && cp -i "${@:1:$#-1}" "$where"
	)
}

# Appends a file from the provider directory to the invoke directory
#
# $1: The file to append (relative to the provider directory)
# $2: The target file (relative to the invoke directory)
package_fs_append_file() {
	local from="$PM_PROVIDER_DIR/$1"
	local to="$PM_INVOKE_DIR/$2"

	if [[ "$(paths_is_directory "$to")" == y ]]; then
		to="$to/$(basename "$from")"
	fi

	mkdir -p "$(dirname "$to")"

	cat "$from" >> "$to"
}
