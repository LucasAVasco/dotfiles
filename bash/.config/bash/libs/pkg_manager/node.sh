#!/bin/bash
#
# Module to manage Node packages

pkg_manager_node_default_manager='pnpm'

# Get the name of the package manager for a Node project.
#
# $1: path to the Node project.
# $2: default value to return if the package manager is not found.
#
# Return the package manager name or the default one.
pkg_manager_node_get_manager_name() {
	local project_path="$1"
	local default_manager="${2:-$pkg_manager_node_default_manager}"

	local manager=$(cat "$project_path/package.json" | jq -r '.packageManager' | cut -d '@' -f 1)

	if [[ "$manager" == 'null' ]]; then
		manager="$default_manager"
	fi

	echo "$manager"
}

# Initialize a Node project.
#
# $1: path to the Node project.
# $2: package manager to use.
pkg_manager_node_init() {
	local project_path="$1"
	local manager="$2"

	(
		cd "$project_path"
		"$manager" init
	)
}

# Install Node packages as dependencies.
#
# $1: path to the Node project.
# $2..n: packages to install.
pkg_manager_node_install_packages() {
	local project_path="$1"

	local manager=$(pkg_manager_node_get_manager_name "$project_path")

	(
		cd "$project_path"
		if [[ "$manager" == 'yarn' ]]; then
			yarn add "${@:2}"
		else
			"$manager" install "${@:2}"
		fi
	)
}

# Install Node packages as development dependencies.
#
# $1: path to the Node project.
# $2..n: packages to update.
pkg_manager_node_install_packages_as_dev() {
	local project_path="$1"

	local manager=$(pkg_manager_node_get_manager_name "$project_path")

	(
		cd "$project_path"
		if [[ "$manager" == 'yarn' ]]; then
			echo yarn add --dev "${@:2}"
		else
			"$manager" install -D "${@:2}"
		fi
	)
}

# Remove Node packages.
#
# $1: path to the Node project.
# $2..n: packages to remove.
pkg_manager_node_remove_packages() {
	local project_path="$1"

	local manager=$(pkg_manager_node_get_manager_name "$project_path")

	(
		cd "$project_path"
		if [[ "$manager" == 'yarn' ]]; then
			yarn remove "${@:2}"
		else
			"$manager" uninstall "${@:2}"
		fi
	)
}

# Execute a command in a Node project.
#
# $1: path to the Node project.
# $2..n: command to execute.
pkg_manager_node_exec() {
	local project_path="$1"

	local manager=$(pkg_manager_node_get_manager_name "$project_path")

	(
		cd "$project_path"
		if [[ "$manager" == 'yarn' ]]; then
				yarn exec "${@:2}"
		else
			"$manager" exec -- "${@:2}"
		fi
	)
}
