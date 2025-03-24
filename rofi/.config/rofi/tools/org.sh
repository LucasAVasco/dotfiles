#!/bin/bash
#
# Interface to select a organization type (notes, agenda, etc) and open with 'my-org' script.

# Paths
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)

# Displays Rofi. The '-i' flags sets the case-insensitive search (see `man rofi-dmenu`)
selected_org_type=$(echo -en "Notes\nAgenda\nPages" | rofi -theme "$current_dir/themes/org.rasi" -p '󱓩   Org ' -dmenu -i)

# Opens with the 'my-org' script
if [ "$selected_org_type" != '' ]; then
	selected_org_type=$(echo "$selected_org_type" | tr '[:upper:]' '[:lower:]') # Convert to lower case

	default_term my-org "$selected_org_type"
fi
