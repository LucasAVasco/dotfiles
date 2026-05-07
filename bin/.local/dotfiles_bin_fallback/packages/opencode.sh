#!/bin/bash
#
# OpenCode (https://opencode.ai/) package.

set -e

source ~/.config/bash/libs/install/node.sh

case "$1" in
	i | u)
		install_node_install_package opencode-ai
		;;

	r)
		install_node_remove_package opencode-ai
		;;
esac
