#!/bin/bash
#
# Get the first caps lock device file available.

set -e

devices=$(ls -1 /sys/class/leds/input*::capslock/brightness)
echo -n "$devices" | sed -n 1p
