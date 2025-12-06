#!/bin/bash
#
# Listen to Hyprland events and update the screen color based in the current work-space.

set -e

# Initial status
~/.config/monitor/update-workspace-screen-temp.sh -r 1

# Listen to Hyprland events
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | \
	while read -r line; do
		# The line with a work-space change specification has the following format: 'workspacev2>>${workspace_id},${workspace_name}'
		if [[ "${line:0:11}" == "workspacev2" ]]; then
			workspace=$(echo ${line:13} | cut -d ',' -f 1) # Get the work-space id

			~/.config/monitor/update-workspace-screen-temp.sh "$workspace"

		# When the user changes to another virtual terminal (tty), it raises a 'activelayout' event
		elif [[ "${line:0:12}" == "activelayout" ]]; then
			current_workspace=$(hyprctl activeworkspace -j | jq '.id')
			~/.config/monitor/update-workspace-screen-temp.sh -r "$current_workspace"
		fi
	done
