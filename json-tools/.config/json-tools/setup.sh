#!/bin/bash

# Install dependencies
luarocks install --local lua-cjson
luarocks install --local luv

# First Build
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
"$current_dir/build.sh"
