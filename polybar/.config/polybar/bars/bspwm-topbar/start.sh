#!/bin/bash
#
# Launches a top bar that works with Bspwm, and a system tray bar


# Creates the battery configuration file to be able to use the battery module
~/.config/polybar/scripts/update_battery_device.sh


# Launches the bars. The system tray need to be executed before the other bars in order to be on top of them
config_file=~/.config/polybar/bars/bspwm-topbar/config.ini

polybar --config="$config_file" system-tray &

sleep 0.5

polybar --config="$config_file" topbar &
