#!/bin/bash
#
# Go template executor (see ~/.local/dev/go-template-exec) package.

set -e

source ~/.local/lib/dotfiles/bash/install/go.sh

case "$1" in
	i | u)
		cd ~/.local/dev/go-template-exec/ && go install
		;;

	r)
		install_go_remove_package go-template-exec
		;;
esac
