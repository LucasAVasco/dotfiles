#!/bin/bash
#
# Library to manager Development containers (https://containers.dev/)

source ~/.config/bash/libs/docker.sh
source ~/.config/bash/libs/paths.sh

# List all devcontainers.
#
# $1..n: `docker container ls` options
devcontainer_list() {
    docker container ls --filter='name=devcontainer' "$@"
}

# Send a file from the host to the container as the provided user.
#
# $1: container ID.
# $2: container user.
# $3..n: files or directories to send (file the host machine).
devcontainer_sync_files_as_user() {
	local container_id="$1"
	local container_user="$2"

	for src_file in "${@:3}"; do
		src_file=$(paths_expand_tilde "$src_file")
		src_file=$(paths_ensure_trailing_slash_on_directories "$src_file") # Must be placed after the tilde expansion

		local dest_file=$(paths_replace_user_home "$container_user" "$src_file")

		# Removes old file
		docker_execute_command_in_container "$container_id" '' 'rm' '-rf' "$dest_file"
		docker_execute_command_in_container "$container_id" '' 'mkdir' '-p' "$(dirname $dest_file)"

		# Sends the file
		docker_send_file_to_container "$container_id" "$src_file" "$dest_file"
	done
}

# Send a file from the host to the container as the default container user.
#
# $1: container ID.
# $2..n: files or directories to send (file the host machine).
devcontainer_sync_files() {
	local container_id="$1"

	local container_user=$(docker_get_container_user $container_id)

	devcontainer_sync_files_as_user "$container_id" "$container_user" "${@:2}"
}

# Returns if a lock file already exists.
#
# This library can create lock files that indicates that the host environment is synced with the devcontainer.
# These lock files are created in the user home directory.
#
# $1: container ID.
# $2: lock file name.
#
# Returns 'y' or 'n'
devcontainer_has_lock_file() {
	local container_id="$1"
	local lock_file_name="$2"

	local container_user=$(docker_get_container_user "$container_id")
	local dest_file="/home/$container_user/$lock_file_name"

	docker_execute_command_in_container "$container_id" '' 'ls' "$dest_file" > /dev/null 2>&1 && echo y || echo n
}

# Creates the lock file in a container.
#
# This library can create lock files that indicates that the host environment is synced with the devcontainer.
# These lock files are created in the user home directory.
#
# $1: container ID.
# $2: lock file name.
devcontainer_create_lock_file() {
	local container_id="$1"
	local lock_file_name="$2"

	local container_user=$(docker_get_container_user "$container_id")
	local dest_file="/home/$container_user/$lock_file_name"

	docker_execute_command_in_container "$container_id" '' 'touch' "$dest_file"
}
