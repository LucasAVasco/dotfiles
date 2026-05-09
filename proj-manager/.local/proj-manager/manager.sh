#!/bin/bash
#
# Simple project manager

set -e

source ~/.config/bash/libs/help.sh
source ~/.config/bash/libs/dialog/dialog.sh
source ~/.local/proj-manager/libs/package_run.sh

help_handle n "$@" << EOF
	Project manager

	USAGE
	./manager.sh init [project_name]
		Run a initialization script for a project. If no project name is given, a project will be interactively selected

	./manager.sh add [project_name]
	./manager.sh extend [project_name]
		Run a extension script for a project. If no project name is given, a project will be interactively selected

	./manager.sh update [project_name]
		Run a update script for a project. If no project name is given, a project will be interactively selected

	./manager.sh create <provider-path>
		Create a provider script for a project.
EOF

# Directory that the user was when the CLI was called
export PM_INVOKE_DIR=$(pwd)

# Runs all commands in the current directory
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

# Select a folder that contains a file
#
# $1: The file to select to search
# $2: The base directory to search
#
# stdout: The selected folder relative to the base directory
select_folder_with_file() {
	fd --format='{//}'  "$package_run_proj_manager_file_basename" "$@" | \
		fzf --preview="echo -e '# File contents:\n' && pretty-preview {}/$package_run_proj_manager_file_basename \
		&& echo -e '\n# Folder contents:\n' && pretty-preview {}"
}

# Select a provider script and run it
#
# $1: The folders to search for the provider script, separated by spaces
# $2..n: The arguments to pass to the provider
select_script_and_run() {
	folders=($1)
	shift

	if [[ "$1" == '' ]]; then
		proj=$(select_folder_with_file "${folders[@]}")
	else
		proj="$1"
	fi

	initialize=$(dialog_ask_boolean "Are you sure you want to run project '$proj'?" n)
	if [[ "$initialize" == y ]]; then
		package_run_provider "$proj" "${@:2}"
	else
		echo "Aborted"
		exit 1
	fi
}

main_command="$1"
if [[ "$main_command" != '' ]]; then
	shift
fi

case "$main_command" in
	'')
		select_script_and_run "./init-proj ./extend-proj ./update-proj" "$@"
		;;

	init)
		select_script_and_run "./init-proj" "$@"
		;;

	add | extend)
		select_script_and_run "./extend-proj" "$@"
		;;

	update)
		select_script_and_run "./update-proj" "$@"
		;;

	create)
		folder="$1"
		file="$folder/$package_run_proj_manager_file_basename"

		# Validation (folder must be inside 'init-proj/', 'extend-proj/' or 'update-proj/')
		if ! [[ \
			"$folder" == init-proj/* || \
			"$folder" == ./init-proj/* || \
			"$folder" == extend-proj/* || \
			"$folder" == ./extend-proj/* || \
			"$folder" == update-proj/* || \
			"$folder" == ./update-proj/* \
		]]; then
			echo "Invalid folder: '$folder'. Must be inside 'init-proj', 'extend-proj' or 'update-proj'" >&2;
			exit 1
		fi

		# Create the provider folder and its script if it doesn't exist
		mkdir -p "$folder"
		if [[ ! -f "$file" ]]; then
			echo '#!/bin/bash' >> "$file"
		fi
		chmod u+x "$file"
		;;

	*)
		echo "Invalid command: '$main_command'" >&2
		exit 1
		;;
esac
