#!/bin/bash
#
# Change the current desktop directory with Rofi


# Paths
current_dir=$(realpath -m -- "$0/../")
chdesk_cmd="chdesk"


# Gets the content
content=$("$chdesk_cmd" ls-names)

# Displays Rofi
selected_desktop=$(echo -en "$content" | rofi -theme "$current_dir/themes/chdesk.rasi" -p 'Desktop:' -dmenu)

# Changes to `selected_desktop`
if [ "$selected_desktop" != '' ]; then
	"$chdesk_cmd" change "$selected_desktop"
fi
