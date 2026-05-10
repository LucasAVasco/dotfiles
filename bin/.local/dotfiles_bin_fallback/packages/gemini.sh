#!/bin/bash
#
# Gemini CLI (@google/gemini-cli) package.

set -e

source ~/.local/lib/dotfiles/bash/install/node.sh

case "$1" in
	i | u)
		install_node_install_package '@google/gemini-cli'
		;;

	r)
		install_node_remove_package '@google/gemini-cli'
		;;
esac
