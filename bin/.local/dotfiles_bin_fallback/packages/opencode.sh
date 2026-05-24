#!/bin/bash
#
# OpenCode (https://opencode.ai/) package.

set -e

source ~/.local/lib/dotfiles/bash/install/node.sh

case "$1" in
	i | u)
		install_node_install_package opencode-ai
		node "$(pnpm root -g)/opencode-ai/postinstall.mjs"
		;;

	r)
		install_node_remove_package opencode-ai
		;;
esac
