#!/bin/bash
#
# Yeoman (https://yeoman.io/) package.

set -e

source ~/.local/lib/dotfiles/bash/install/node.sh

case "$1" in
	i | u)
		install_node_install_package 'yo'
		;;

	r)
		install_node_remove_package 'yo'
		;;
esac
