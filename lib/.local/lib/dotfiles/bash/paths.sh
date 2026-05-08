#!/bin/bash
#
# Utilities for working with file/directory paths

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
