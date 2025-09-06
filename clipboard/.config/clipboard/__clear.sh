#!/bin/bash
#
# Clear the user clipboard. This is a internal script used by './clear.sh'. Do not use this script directly, use the './clear.sh' script.

# Ensures the clipboard is cleared after the script ends, even if an error occurs or the user kills the process
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
trap "$current_dir/__clear_now.sh" EXIT

# Exits on error
set -e

# Parses the arguments
show_notification=y
if [[ "$1" == '--no-notify' ]]; then
	show_notification=n
	shift
fi

# Waits this time before to clear the clipboard
time_to_wait="$1"
if [[ -n "$time_to_wait" ]]; then
	sleep "$time_to_wait"
fi

# Clears the clipboard without any delay or notification
"$current_dir/__clear_now.sh"

# Shows a notification at the end
if [[ $show_notification == y ]]; then
	notify-send 'Clipboard cleared' "Cleared at $(date '+%Hh %Mmin %Ss')"
fi

# Can remove all other instances (clipboard already cleaned)
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
nohup pkill -u "$USER" -f "$current_dir/__clear.sh" > /dev/null 2>&1
