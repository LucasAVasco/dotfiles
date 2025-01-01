#!/bin/bash
#
# Launches a top bar that works with Qtile


# Creates the battery configuration file to be able to use the battery module
~/.config/polybar/scripts/update_battery_device.sh


# Launches the bars
config_file=~/.config/polybar/bars/qtile_topbar/config.ini
polybar --config="$config_file" topbar &
