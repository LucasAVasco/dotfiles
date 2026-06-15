#!/bin/bash
#
# Usage:
#   ./run-in-container.sh [-d | --detach] [--name NAME] [--engine ENGINE] [--dbus]
#
# Flags:
#   -d, --detach      Run the container in the background
#   --name NAME       Set the name of the container. Default to a random name if not provided (it will be removed when the script ends)
#   --dbus            Expose the D-Bus socket
#   --engine ENGINE   Use the specified container engine. Default to the first available engine (podman takes precedence over docker)

set -euo pipefail

# Parse command line arguments
detach=n
container_name=''
expose_dbus=n
if command -v podman >/dev/null 2>&1; then
	container_engine='podman'
elif command -v docker >/dev/null 2>&1; then
	container_engine='docker'
fi
while [[ $# -gt 0 ]]; do
	case "$1" in
		-d|--detach)
			detach=y
			shift
			;;

		--name)
			container_name="$2"
			shift 2
			;;

		--dbus)
			expose_dbus=y
			shift
			;;

		--engine)
			container_engine="$2"
			shift 2
			;;

		*)
			break
			;;
	esac
done

if [[ -z "$container_engine" ]]; then
	echo 'No container engine selected' >&2
	exit 1
fi

# Download the notification-bridge if it doesn't exist
#
# Return the path to the notification-bridge executable
ensure_download_notification_bridge() {
	# Check if the notification-bridge is already installed and available in the PATH
	if command -v container-notification-bridge >/dev/null 2>&1; then
		echo -n container-notification-bridge
		return
	fi

	# Check if the notification-bridge is already downloaded and available in the cache
	local executable="$HOME/.cache/dotfiles_in_container/container-notification-bridge"
	if [[ -f "$executable" ]]; then
		echo -n "$executable"
		return
	fi

	# Download
	local repository='https://github.com/LucasAVasco/container-notification-bridge'
	local version='v1.0.2'
	curl -L "$repository/releases/download/$version/container-notification-bridge-$(uname -m)" \
		--output "$executable"

	# Permissions
	chmod u+x "$executable"

	# Return the path
	echo -n "$executable"
}

# Execute the script inside the current directory if it is executed directly from the file (not form a stdin or a file descriptor) inside
# a home directory
if [[ -n "${BASH_SOURCE:-}" && "${BASH_SOURCE[0]}" =~ /home/* ]]; then
	current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
	cd "$current_dir"
fi

# Ensure the cache directory exists
cache_dir="$HOME/.cache/dotfiles_in_container"
mkdir -p "$cache_dir"

# Handle arguments
args=()
if [[ "$detach" == 'y' ]]; then
	args+=('--detach')
fi

if [[ -n "$container_name" ]]; then
	args+=('--name' "$container_name")
else
	args+=('--rm')
fi

if [[ "$expose_dbus" == y ]]; then
	args+=(-v "/run/user/$(id -u):/run/user/$(id -u)")
	args+=(-e "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus")
else
	notification_bridge_dir="/run/user/$(id -u)/container-notification-bridge/"
	args+=(-v "$notification_bridge_dir:/container-notification-bridge-root:z")
	notification_bridge_path="$(ensure_download_notification_bridge)"
	export CONTAINER_NOTIFICATION_BRIDGE_SOCKET="$notification_bridge_dir/socket"
	"$notification_bridge_path" host &
	sleep 0.5
fi

# Get the command to run inside the container
if [[ -f ./_configure-in-container.sh ]]; then
	container_command=$(cat ./_configure-in-container.sh)
else
	container_command=$(curl https://raw.githubusercontent.com/LucasAVasco/dotfiles/refs/heads/main/_configure-in-container.sh)
fi

# Main user name to use in the container
main_user="$(id -un)"
main_user="${main_user%%_dev}" # Remove '_dev' suffix
read -p "Proceed with username '$main_user'? [Y/n]: " proceed
if [[ "$proceed" == n || "$proceed" == N ]]; then
	read -p "Main user name: " main_user
fi

# Run the container
"$container_engine" run -u root -it \
	-v "$HOME:/host" "${args[@]}" \
	-e "MAIN_USER=$main_user" \
	"${args[@]}" \
	archlinux:latest /bin/bash -c "$container_command"
