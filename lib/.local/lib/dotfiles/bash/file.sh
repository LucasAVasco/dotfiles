#!/bin/bash

# Remove a region from a file.
#
# $1: AWK pattern of the region's beginning (line).
# $2: AWK pattern of the region's ending (line).
# $3: Path of the file to be removed a unwanted region from.
#
# $stdout: content of the file without the region
file_remove_region() {
	local begin_pattern="$1"
	local end_pattern="$2"
	local file="$3"

	awk "/$begin_pattern/{show_line=1}; show_line==0 {print}; /$end_pattern/{show_line=0}" "$3"
}

# Replaces the first block of lines delimited by start_regex and end_regex (inclusive).
#
# $1: target file path.
# $2: start regex (grep regex).
# $3: end regex (grep regex).
# $4: replacement text.
#
# Prints 'y' if the block was found and replaced, or 'n' otherwise.
file_replace_block() {
	local file="${1:?Missing target file path}"
	local start_regex="${2:?Missing start regex}"
	local end_regex="${3:?Missing end regex}"
	local replacement="${4-}"

	if [[ ! -f "$file" || ! -r "$file" || ! -w "$file" ]]; then
		echo "n"
		return 1
	fi

	# Locate the first line matching the opening delimiter
	local start_line
	start_line=$(grep -nE -- "$start_regex" "$file" | head -n 1 | cut -d: -f1)

	if [[ -z "$start_line" ]]; then
		echo "n"
		return 0
	fi

	# Locate the first line matching the closing delimiter after the start line
	local end_offset
	end_offset=$(tail -n +"$((start_line + 1))" "$file" | grep -nE -- "$end_regex" | head -n 1 | cut -d: -f1)

	if [[ -z "$end_offset" ]]; then
		echo "n"
		return 0
	fi

	local end_line=$((start_line + end_offset))

	# Create temporary file in the same directory to ensure atomic mv on the same filesystem
	local tmp_file
	tmp_file=$(mktemp "$(dirname -- "$file")/.tmp.XXXXXX") || {
		echo "n"
		return 1
	}

	# Ensure temporary file is removed if an error occurs before moving
	trap 'rm -f -- "$tmp_file"' RETURN

	# Preserve original file permissions and ownership attributes where possible
	chmod --reference="$file" "$tmp_file" 2>/dev/null || true

	# Reconstruct the file with the updated block
	{
		if (( start_line > 1 )); then
			head -n "$((start_line - 1))" "$file"
		fi
		printf "%s\n" "$replacement"
		tail -n +"$((end_line + 1))" "$file"
	} > "$tmp_file" && mv -f -- "$tmp_file" "$file" || {
		echo "n"
		return 1
	}

	echo "y"
	return 0
}
