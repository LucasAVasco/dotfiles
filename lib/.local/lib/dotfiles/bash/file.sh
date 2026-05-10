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
