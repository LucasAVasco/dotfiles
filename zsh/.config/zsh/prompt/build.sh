#!/bin/bash
#
# Build the prompts.
#
# Dependencies:
# * Bash
# * Cmake
# * Make
# * G++

set -e

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)

# Notfication
echo "Building the prompts..."

# Configuration
build_dir="$current_dir/build"
[[ -d "$build_dir" ]] && rm -r "$build_dir"
cd "$current_dir"
cmake --preset default

# Building
cmake --build build/

# returning to last directory
cd -
