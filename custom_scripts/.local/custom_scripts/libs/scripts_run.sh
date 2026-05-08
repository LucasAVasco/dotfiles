#!/bin/bash
#
# Functions to run scripts

# Run a script.
#
# $1: script path absolute or relative to the current working directory
scripts_run_script() {
	local script="$(realpath -m -- "$1")"

	(
		export CUSTOM_SCRIPT_CURRENT_SCRIPT="$script"
		export CUSTOM_SCRIPT_CURRENT_SCRIPT_DIR="$(dirname "$script")"

		cd "$CUSTOM_SCRIPT_CURRENT_SCRIPT_DIR"
		"$script"
	)
}


# Get a command to run a script
#
# $1: script path absolute or relative to the current working directory
scripts_run_get_command() {
	local script="$(realpath -m -- "$1")"
	script="$(realpath --relative-to="$CUSTOM_SCRIPT_MANAGER_DIR" "$script")"

	echo "$CUSTOM_SCRIPT_MANAGER_PATH" run "$script"
}
