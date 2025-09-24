#!/bin/bash
#
# Package manager of the fallback installers.

source ~/.config/bash/libs/help.sh

help() {
	help_msg_format '\t\t' << EOF
		Package manager of the fallback installers.

		USAGE:

		./manager.sh install | add <package>
			Install a package.

		./manager.sh update <package>
			Update a package.

		./manager.sh uninstall | remove | rm <package>
			Uninstall a package.

		./manager.sh ls | list
			List all packages.
EOF
}

help_call_help_function help y "$@"

# Only run this script if the user is allowed to install external software
[[ "$ALLOW_EXTERNAL_SOFTWARE" != "y" ]] && {
	notify-send --app-name='Fallback Installer' 'Fallback Installer' 'You are not allowed to install external software.'
}

# Fallback installers library
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"
source ./lib.sh

# Commands
case "$1" in
	install | add)
		run_package_script "$2" i
		;;

	update)
		run_package_script "$2" u
		;;

	uninstall | remove | rm)
		run_package_script "$2" r
		;;

	ls | list)
		list_packages
		;;

	*)
		echo "Unknown command '$1'." >&2
		;;
esac
