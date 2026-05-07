#!/bin/bash
#
# Simple project manager

set -e

source ~/.config/bash/libs/help.sh
source ~/.config/bash/libs/dialog/dialog.sh
source ~/.local/proj-manager/libs/package_run.sh

help_handle y "$@" << EOF
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
	local file="$1"
	local base_search="$2"

	# Executed inside a sub-shell so it doesn't change the current directory
	(
		cd "$base_search" && fd "$file" --format={//} | \
			fzf --preview="echo -e '# File contents:\n' && pretty-preview {}/$file \
			&& echo -e '\n# Folder contents:\n' && pretty-preview {}"
	)
}

main_command="$1"
shift
case "$main_command" in
	init)
		if [[ "$1" == '' ]]; then
			proj=$(select_folder_with_file "$package_run_proj_manager_file_basename" ./init-proj/)
		else
			proj="$1"
		fi

		initialize=$(dialog_ask_boolean "Are you sure you want to initialize project '$proj'?" n)
		if [[ "$initialize" == y ]]; then
			package_run_init_provider "$proj" "$@"
		else
			echo "Aborted"
			exit 1
		fi
		;;

	add | extend)
		if [[ "$1" == '' ]]; then
			proj=$(select_folder_with_file "$package_run_proj_manager_file_basename" ./extend-proj/)
		else
			proj="$1"
		fi

		extend=$(dialog_ask_boolean "Are you sure you want to extend current project with '$proj'?" n)
		if [[ "$extend" == y ]]; then
			package_run_extend_provider "$proj" "$@"
		else
			echo "Aborted"
			exit 1
		fi
		;;

	update)
		if [[ "$1" == '' ]]; then
			proj=$(select_folder_with_file "$package_run_proj_manager_file_basename" ./update-proj/)
		else
			proj="$1"
		fi

		script=$(dialog_ask_boolean "Are you sure you want to update current project with '$proj'?" n)
		if [[ "$script" == y ]]; then
			package_run_update_provider "$proj" "$@"
		else
			echo "Aborted"
			exit 1
		fi
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
