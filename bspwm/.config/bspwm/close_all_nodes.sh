#!/bin/bash
#
# Command to close (or kill) all nodes in Bspwm
#
# Command options:
#   -c: close all nodes
#   -k: kill all nodes
#   -h: help


# Parse the option (the default option is '-h')
if [ "$1" == '-c' ]; then
	option="-c"

elif [ "$1" == '-k' ]; then
	option="-k"

else
	option="-h"
fi


# Shows the help message if the user wants it, otherwise execute the command
if [ "$option" == "-h" ]; then
	echo "
	Usage: close-all-nodes [option]
	-c: close all nodes
	-k: kill all nodes
	-h: help
	" | sed 's/^\t*//g'

else
	for current_node in $(bspc query -N); do
		bspc node $current_node "$option"
	done
fi
