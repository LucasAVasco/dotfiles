#!/bin/bash
#
# Podlet (https://github.com/containers/podlet) package.

set -e

source ~/.local/lib/dotfiles/bash/install/rust.sh

case "$1" in
	i | u)
		install_rust_install_package podlet
		;;

	r)
		install_rust_remove_package podlet
		;;
esac
