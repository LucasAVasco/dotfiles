#!/bin/bash
#
# Library to manage Docker containers.


# Get the default user of a container.
#
# $1: container id
# Return string with the name of the user.
docker_get_container_user() {
	local container_id="$1"
	docker inspect --format='{{.Config.User}}' "$container_id"
}

# Execute a command in a running container.
#
# $1: container id.
# $2: user name. If '', will use the default user.
# $3: command.
# $4..n: command's arguments.
docker_execute_command_in_container() {
	local container_id="$1"
	local container_user="$2"

	if [[ -z "$container_user" ]]; then # No user provided
		docker exec -it "$container_id" "${@:3}"
	else # User provided
		docker exec -u "$container_user" -it "$container_id" "${@:3}"
	fi
}

# Send a file from the host to the container.
#
# $1: container ID.
# $2: source file (host machine).
# $3: destination file (container).
docker_send_file_to_container() {
	local container="$1"
	local src_file="$2"
	local dest_file="$3"

	docker cp "$src_file" "$container:$dest_file"
}
