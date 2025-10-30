#!/bin/bash

# Change to the directory of this script
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

# Must reload the bars after exiting the lock screen. Ensures a delay
sleep 1
../../scripts/reload-bars.sh
