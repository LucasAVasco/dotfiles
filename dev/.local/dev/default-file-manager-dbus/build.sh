#!/bin/bash
#
# Builds/rebuilds the D-Bus daemon.

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

cmake -B build -S .
cmake --build build
