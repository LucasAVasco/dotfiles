#!/bin/bash
#
# Library to manage private registries

# Get the container name of a registry
#
# $1: registry name
__registry_get_container() {
	echo "k3s-mgr-$1"
}

# Check if a registry exists
#
# $1: registry name
__registry_exists() {
	local container=$(__registry_get_container "$1")

	if docker container inspect "$container" >/dev/null 2>&1; then
		echo y
	else
		echo n
	fi
}

# Check if a registry is running
#
# $1: registry name
__registry_is_running() {
	local registry="$1"
	local container=$(__registry_get_container "$1")

	if [[ $(__registry_exists "$registry") == n ]]; then
		echo -n n
		return
	fi

	if [[ $(docker container inspect "$container" --format=json | jq -r '.[].State.Status') == 'running' ]]; then
		echo -n y
	else
		echo -n n
	fi
}

# Create a registry. Fail if the registry already exists
#
# $1: registry name
# $2: local host port. Exports the container in this port. Defaults to 5000
registry_create() {
	local registry="$1"
	local port=${2:-5000}

	if [[ $(__registry_exists "$registry") == y ]]; then
		echo "Registry $registry already exists" >&2
		exit 1
	fi

	docker run -d \
		--name "$(__registry_get_container "$registry")" \
		-p "$port:5000" \
		registry:2
}

# Start a already created registry
#
# $1: registry name
registry_start() {
	local registry="$1"

	if [[ $(__registry_is_running "$registry") == y ]]; then
		echo "Registry $registry is already running" >&2
		exit 1
	fi

	docker start "$(__registry_get_container "$registry")"
}

# Stop a running registry. Does not delete the registry
#
# $1: registry name
registry_stop() {
	local registry="$1"

	if [[ $(__registry_is_running "$registry") == n ]]; then
		echo "Registry $registry is not running" >&2
		exit 1
	fi

	docker stop "$(__registry_get_container "$registry")"
}

# Stop and delete a registry
#
# $1: registry name
registry_delete() {
	local registry="$1"
	if [[ $(__registry_exists "$registry") == n ]]; then
		echo "Registry $registry does not exist" >&2
		exit 1
	fi

	if [[ $(__registry_is_running "$registry") == y ]]; then
		registry_stop "$registry"
	fi

	docker rm "$(__registry_get_container "$registry")"
}
