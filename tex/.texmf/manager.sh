#!/bin/bash
#
# Script to manage LaTeX projects that build PDFs.

# Directory of the project
proj_dir="$PWD"

# Changes to the directory of this script
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

# Main command
command="$1"
shift 1

case "$command" in
	init)
		cp -i ./template/Makefile "$proj_dir"
		cp -i ./template/conf.sh "$proj_dir"
		cp -i ./template/tex-fmt.toml "$proj_dir"
		cp -i ./template/.editorconfig "$proj_dir"
		;;

	update)
		cp -i ./template/Makefile "$proj_dir"
		;;

	*)
		echo "Unknown command: $command" >&2
		exit 1
		;;
esac
