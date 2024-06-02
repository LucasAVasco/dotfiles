#!/bin/bash
#
# Interface to manage the flags and layers of a Bspwm node. Interactively change the flags and layers with Rofi


# Paths
current_dir=$(realpath -m -- "$0/../")


# Get the state of a flag of the current node
#
# Parameters:
# $1: Flag name
#
# Return:
# 'true' or 'false'
get_node_flag_state()
{
	text_with_state_true=$(echo "$node_information" | awk "/\"$1\":true/")

	if [ "$text_with_state_true" != '' ]; then
		echo true
	else
		echo false
	fi
}


# Add a marker icon that indicates if the option is enabled
#
# Parameters:
# $1: 'true' or 'false'. If it's 'true', return the marker
#
# Return:
# A string that shows the marker when sent to Rofi
add_marker()
{
	if [ "$1" == 'true' ]; then
		echo '\0icon\x1f'"$current_dir/icons/blue-circle.png"
	fi
}


# Node flags information
node_information=$(bspc query -T -n) || exit

is_sticky=$(get_node_flag_state sticky)
is_private=$(get_node_flag_state private)
is_locked=$(get_node_flag_state locked)
is_marked=$(get_node_flag_state marked)

# Node layer information
layer=$(echo "$node_information" | sed 's/^.*"layer":"//g' | sed 's/".*$//g')

is_below='false'
is_normal='false'
is_above='false'

case "$layer" in
	below )
		is_below='true'
	;;
	normal )
		is_normal='true'
	;;
	above )
		is_above='true'
	;;
esac

# Content to be sent to Rofi
content='Hidden\n'
content="${content}Sticky"$(add_marker $is_sticky)'\n'
content="${content}Private"$(add_marker $is_private)'\n'
content="${content}Marked"$(add_marker $is_marked)'\n'
content="${content}Locked"$(add_marker $is_locked)'\n'
content="${content}Below"$(add_marker $is_below)'\n'
content="${content}Normal"$(add_marker $is_normal)'\n'
content="${content}Above"$(add_marker $is_above)'\n'

# Runs Rofi
selected_option=$(echo -en "$content" | rofi -theme "$current_dir/themes/nodes.rasi" -dmenu)

# Changes the option state
case "$selected_option" in
	'Hidden' ) bspc node --flag hidden;;
	'Sticky' ) bspc node --flag sticky;;
	'Private' ) bspc node --flag private;;
	'Marked' ) bspc node --flag marked;;
	'Locked' ) bspc node --flag locked;;
	'Below' ) bspc node --layer below;;
	'Normal' ) bspc node --layer normal;;
	'Above' ) bspc node --layer above;;
esac
