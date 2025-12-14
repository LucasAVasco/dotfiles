#!/bin/bash
#
# Download a plugin repository at '../repos/'
#
# $1: Repository URL (`git clone` style)

# Execute all commands from the current directory
__install_current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
__repos_dir="$(dirname "$__install_current_dir/")/repos"

# Ensures the './repos/' folder exists
mkdir -p "$__repos_dir"

# Install a VIFM plugin at the '../repos/' folder
#
# $1: Repository URL
install_plugin() {
	local repo="$1"
	local dest="$__repos_dir/$(basename "$repo")"

	if [[ -d "$dest" ]]; then
		cd "$dest"
		git pull
		cd -
	else
		git clone --depth 1 "$repo" "$dest"
	fi
}

# Must be called at the end of the plugin installation (after all plugins are installed)
install_end() {
	touch "$__repos_dir/.installed"
}
