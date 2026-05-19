#!/bin/bash
#
# This script is used to run custom scripts. It allows the user to list and interactively select a script to run.
#
# The scripts are in the 'scripts' directory. Files inside a 'lib' directory are not considered scripts to run. So the user
# can place common modules in 'lib/' directories inside the 'scripts/' directory.
#
# To list the scripts, use the `ls` command. You can also open a shell in the scripts base directory with the `cd` command

set -e

source ~/.local/lib/dotfiles/bash/help.sh

last_executed_script_dconf_key='/apps/custom-desktop/last-executed-script'

# Manager executable
if [[ -z "$CUSTOM_SCRIPT_MANAGER_EXECUTABLE" ]]; then
	CUSTOM_SCRIPT_MANAGER_EXECUTABLE="$PWD/manager.sh"
fi
manager_command="$CUSTOM_SCRIPT_MANAGER_EXECUTABLE"

help_handle n "$@" <<EOF
	This script is used to run custom scripts. It allows the user to list and interactively select a script to run.

	Usage:
		$manager_command run [script-name]
			Run a script. The script name must be relative to the custom scripts directory. This means that the proided path must begin with
			'scripts/' or './scripts/'. If omitted, the script will be selected interactively

		$manager_command run-last
			Re-run the last executed script

		$manager_command get-root-dir
			Print the root directory of the custom scripts directory (absolute path)

		$manager_command cd
			Open a new shell instance in the custom scripts directory

		$manager_command ls
			List the scripts

	Environment variables:
		CUSTOM_SCRIPT_MANAGER_EXECUTABLE
			The 'run' command shows the equivalent command that can be used to re-run the selected script. This environment variable can be
			used to override the path of the manager script that is used in that case
EOF

# Environment variables
export CUSTOM_SCRIPT_INVOKE_DIR="$(pwd)"

manager_path=`realpath "${BASH_SOURCE[0]}"`
manager_dir=$(dirname "$manager_path")
export CUSTOM_SCRIPT_MANAGER_DIR="$manager_dir"
export CUSTOM_SCRIPT_MANAGER_PATH="$manager_path"

# Execute the command in the current directory
cd "$manager_dir"

# Library to run scripts
source ./libs/scripts_run.sh

# Handle user command
main_command="$1"
if [[ -n "$1" ]]; then
	shift
fi

case "$main_command" in
	run|'')
		# Script to run
		if [[ -z "$1" ]]; then
			script="$(cd 'scripts/' && find * -type f -not -regex '.*/lib/.*' | fzf --preview="pretty-preview '{1}'")"
			script="./scripts/${script}"
		else
			script="$1"
		fi

		if [ -z "$script" ]; then
			exit 1
		fi

		# The script must be in the 'scripts/' directory
		if ! [[ "$script" =~ ^(\./)?scripts/ ]]; then
			echo "Invalid script path: $script" >&2
			exit 1
		fi

		# Run the script
		scripts_run_script "$manager_dir/$script"

		# Save the last executed script
		dconf write "$last_executed_script_dconf_key" "'$script'"

		# Print a command that can be used to re-run the script
		echo "equivalent command: '$CUSTOM_SCRIPT_MANAGER_EXECUTABLE' run '$script'"
		;;

	run-last)
		script="$(dconf read "$last_executed_script_dconf_key")"

		if [ -z "$script" ]; then
			exit 1
		fi

		# Remove quotes
		script="${script:1}"
		script="${script:0:${#script}-1}"

		# Run the script
		scripts_run_script "$manager_dir/$script"
		;;

	ls)
		find * -type f -not -regex '.*/lib/.*'
		;;

	get-root-dir)
		pwd
		;;

	cd)
		shell="$CD_SHELL"
		if [[ -z "$shell" ]]; then
			shell="${SHELL-bash}"
		fi
		command "$shell" "$@"
		;;

	*)
		echo "Unknown command: $main_command" >&2
		exit 1
		;;
esac
