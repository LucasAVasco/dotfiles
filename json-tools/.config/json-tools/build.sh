#!/bin/bash
#
# Builds the Lua files and generates the 'luac' files.

# Ensures the current directory
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

# Build directory
test -d build && trash build
mkdir build

# Building
find . -type f -name "*.lua" | while read file; do
	# Ensures the output directory exists
	dir=$(dirname "$file")
	mkdir -p "build/$dir"

	# Builds the files
	stem=$(basename "$file" '.lua')
	luac -o "build/$dir/$stem.luac" -- "$file"
done
