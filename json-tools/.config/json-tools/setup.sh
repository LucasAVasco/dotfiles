#!/bin/bash
#
# Initial setup for 'json-tools'. Must at least once.

# Does not run this script if the user can not install external software
[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && {
	echo "This script requires external software to be installed." >&2
	exit 1
}

# Install dependencies
luarocks install --local lua-cjson
luarocks install --local luv

# First Build
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
"$current_dir/build.sh"
