#!/bin/bash
#
# General installation script. All the effective installation scripts at './build/installers/' are symbolic links this script. This script
# gets the tool name by the symbolic link file (available as "$0") and run its respective installation script at './packages/'

set -e

# Libraries
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"
source "./lib.sh"

source ~/.config/bash/libs/bin.sh

# Only runs the installation script if the user is allowed to install external software
[[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ]] && {
	notify 'ERROR' 'You are not allowed to install external software.'
	exit 1
}

# Returns the executable name (stem + extension).
#
# $1: Executable name or path.
get_executable_name() {
	basename "$1"
}

# Returns the executable path.
#
# $1: Executable name or path.
get_executable_path() {
	local name=$(get_executable_name "$1")
	bin_get_executable_path "$name"
}

# Installs a package if it is not installed.
#
# Has protection against recursive calls.
#
# $0: Executable path or base name.
install_package() {
	local executable_name=$(get_executable_name "$1")

	local fallback_executable_path=$(get_executable_path "$1")
	local fallback_executable_top_dir=$(realpath --logical -m -- "$fallback_executable_path/../")

	# Abort if the fallback executable is called more than once
	if [[ "$FALLBACK_RUNNING" == "$executable_name" ]]; then
		notify 'ERROR' "Recursive call to '$executable_name' fallback script.\nMaybe the installation script could not install it."
		exit 1
	fi

	# Ensures that the installer will only run if the original executable does not exist
	if [[ "$fallback_executable_top_dir" != "$DOTFILES_FALLBACK_SCRIPTS" ]]; then
		notify '' "Executable '$executable_name' already installed."
		return
	fi

	# Runs the package script
	notify '' "Installing: '$executable_name'..."
	run_package_script "$executable_name" i
	notify '' "'$executable_name' installed!"
}

# Runs the executable that has been installed.
#
# Has protection against recursive calls.
#
# $0: Executable path or base name.
# $1..n: Arguments to the executable.
run_executable() {
	local executable_name=$(get_executable_name "$1")

	# Abort if the fallback executable is called more than once
	if [[ "$FALLBACK_RUNNING" == "$executable_name" ]]; then
		notify 'ERROR' "Recursive call to '$executable_name' fallback script.\nMaybe the installation script could not install it."
		exit 1
	fi
	export FALLBACK_RUNNING="$executable_name"

	# Calling the installed executable
	`get_executable_path "$1"` "${@:2}"
}

# Main
install_package "$0"
run_executable "$0" "$@"
