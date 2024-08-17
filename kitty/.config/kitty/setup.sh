#!/bin/bash
#
# Generate the configuration file if it does not exist
#
# This repository does not track the default kitty configuration file (kitty.conf). See the './main.conf' file for further information


config_file=~/.config/kitty/kitty.conf


if [[ ! -f "$config_file" ]]; then
	echo 'include main.conf' > "$config_file"
fi
