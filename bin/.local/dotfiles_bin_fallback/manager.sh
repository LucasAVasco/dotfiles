#!/bin/bash
#
# Package manager of the fallback installers.

set -e

source ~/.local/lib/dotfiles/bash/help.sh

help_handle y "$@" << EOF
	Package manager of the fallback installers.

	Usage:

	./manager.sh has <package>
		Check if a package exists (may not be installed). Returns 'y' or 'n'

	./manager.sh is-installed <package>
		Check if a package is installed. Returns 'y' or 'n'

	./manager.sh install | add <package>
		Install a package.

	./manager.sh update <package>
		Update a package.

	./manager.sh uninstall | remove | rm <package>
		Uninstall a package.

	./manager.sh ls | list
		List all packages.
EOF

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
	has )
		test -f "$current_dir/packages/${2}.sh" && echo -n 'y' || echo -n 'n'
		;;

	is-installed )
		is_installed "$2"
		;;

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
