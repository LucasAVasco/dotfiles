#!/bin/bash
#
# Command to show all nodes in Bspwm. By default, only the nodes of the current desktop are shown.
# If the user specifies the '-a' option, all nodes of all desktops are shown.
#
# Command options:
#   -a: all desktops
#   -h: help


# Gets nodes
if [ "$1" == '-h' ]; then
	echo "
	Usage: show-all-nodes [option]
	-a: all desktops
	-h: help
	" | sed 's/^\t*//g'

elif [ "$1" == '-a' ]; then
	# All desktops
	nodes=$(bspc query -N)

else
	# Current desktop
	nodes=$(bspc query -N -d)
fi


# Shows nodes
for current_node in $nodes; do
	bspc node $current_node -g hidden=off
done
