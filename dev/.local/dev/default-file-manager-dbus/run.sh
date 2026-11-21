#!/bin/bash
#
# Run the D-Bus daemon. Automatically builds it if not built.

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

if [[ ! -d ./build/ ]]; then
	./build.sh
fi

exec ./build/default-file-manager-dbus
