#!/bin/bash
#
# Build the 'diff-dir' project.

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

cmake -B build -S .
cmake --build build
