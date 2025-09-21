#!/bin/bash
#
# Module to install Golang packages.

source ~/.config/bash/libs/bin.sh

# Install a go package. Requires Go to be installed to work.
#
# $1: go package to install.
install_go_install_package() {
	local package="$1"
	go install "$package"
}

# Remove a go package.
#
# $1: go package to remove.
install_go_remove_package() {
	local executable="$1"

	# Aborts if it is not installed in a Go directory
	if [[ $(bin_executable_is_inside_dir_regex "$executable" "go/.*/bin") == n ]]; then
		return
	fi

	# Removes the executable
	local path=$(bin_get_executable_path "$executable")
	trash "$path"
}
