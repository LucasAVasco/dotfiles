#!/bin/bash
#
# Functions related to file types.

declare -A __file_type_extension_to_ft=(
	["m"]="octave"
	["py"]="python"
	["md"]="markdown"
)

# Get the file type from the provided file
#
# $1: file name or path
#
# Return a string with the file type or an empty string if can not find it
file_type_get() {
	local file_path="$1"
	local file_name="${file_path##*/}"

	# Try searching to the full extension (text after the first dot). If can not find a extension for it, search for the inner extensions
	# recursively. The extension will the file name in the first iteration and the while loop will retrieve its extension before comparing
	local file_extension="${file_name}"
	while [[ -n "$file_extension" ]]; do
		# Exits if there is not an extension
		if [[ "$file_extension" != *"."* ]]; then
			return
		fi

		# Extracts the inner extension
		local file_extension="${file_extension#*\.}"

		# Check if the current extension value has an associated file type
		local file_type="${__file_type_extension_to_ft[${file_extension}]:-}"
		if [[ -n "$file_type" ]]; then
			printf "%s" "$file_type"
			return
		fi
	done
}

# Get the file type from the provided file, or return the extension if can not find it
#
# $1: file name or path
#
# Return a string with the file type or the file inner extension if can not find it
file_type_get_or_extension() {
	local file_path="$1"

	local file_type="$(file_type_get "$file_path")"
	if [[ -n "$file_type" ]]; then
		printf "%s" "$file_type"
		return
	fi

	printf "%s" "${file_path##*\.}"
}
