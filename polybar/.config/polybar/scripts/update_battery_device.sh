#!/bin/bash
#
# Get the battery device that will be shown in the Polybar and create a configuration file to be used by Polybar.
# Each 'BAT*' folder in the '/sys/class/power_supply/' folder is a battery device


# Polybar only shows one battery device. This script selects the first device (with 'sed') and creates a file with the configuration to add it
# into Polybar battery module. If there are not a battery device, the configuration file will be created without the battery device name. When
# the module is loaded, it will cause an error and disable the battery module. The Polybar will continue without the battery module
device=$(ls -1 /sys/class/power_supply/ | grep '^BAT' | sed 5p)


# Automatically creates the configuration file
mkdir -p ~/.config/polybar/auto/
echo "battery = $device" > ~/.config/polybar/auto/battery_device.ini
