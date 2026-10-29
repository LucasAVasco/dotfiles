#!/bin/bash
#
# Repomix (https://github.com/yamadashy/repomix) package.

set -e

source ~/.local/lib/dotfiles/bash/install/node.sh

case "$1" in
	i | u)
		install_node_install_package repomix
		;;

	r)
		install_node_remove_package repomix
		;;
esac
