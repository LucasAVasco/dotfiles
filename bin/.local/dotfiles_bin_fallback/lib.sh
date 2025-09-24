#!/bin/bash
#
# Library for the fallback installer.

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)

export DOTFILES_FALLBACK_FOLDER="$current_dir"
export DOTFILES_FALLBACK_BIN="$current_dir/bin"
export DOTFILES_FALLBACK_SCRIPTS="$current_dir/build/installers"
export DOTFILES_FALLBACK_LIBS="$current_dir/lib"

# Show a notification to the user.
#
# $1: Summary of the notification.
# $2..n: Body of the notification.
notify() {
	local summary="$1"
	local body=$(echo -en "${@:1}") # Allow the message to have escape characters like '\n'

	if [[ "$summary" == '' ]]; then
		summary='Fallback Installer'
	fi

	notify-send --app-name='Fallback Installer' "$summary" "$body"
	echo "[$summary]" "$body"
}

# Run the package script of a specific executable.
#
# $0: Name of the package (same as the package script, but without extensions).
# $1..n: Arguments to the package script.
run_package_script() {
	local package="$1"

	# Runs the package script
	set -e && cd "$current_dir/packages/" && "./${package}.sh" "${@:2}" >&2
}

# List the available packages.
#
# Returns the names of the available packages (without extension) separated by newlines.
list_packages() {
	for package_file in "$current_dir"/packages/*.sh; do
		basename "$package_file" .sh
	done
}
