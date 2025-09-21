#!/bin/bash
#
# DevContainer CLI (https://github.com/devcontainers/cli) package.

set -e

source ~/.config/bash/libs/install/node.sh

case "$1" in
	i | u)
		install_node_install_package '@devcontainers/cli'
		;;

	r)
		install_node_remove_package '@devcontainers/cli'
		;;
esac
