#!/bin/bash
#
# Show a notification if there are running Docker containers. You can run this script after your desktop environment startup to know if you
# forgot a running container.
#
# The notification has a custom action to stop these containers.
#
# Dependencies:
#
# * Bash
# * Docker
# * `notify-send`
# * `wc`


containers_ids=$(docker ps --format='{{.ID}}')
containers_num=$(echo "$containers_ids" | wc -w)

if [[ $containers_num -gt 0 ]]; then
	response=$(notify-send --urgency=critical \
		--category='presence.online' \
		--action='stop=Stop all docker containers' \
		'Docker' "Active containers number: $containers_num")

	if [[ $response == 'stop' ]]; then
		docker container stop $containers_ids
	fi
fi
