#!/bin/bash
#
# simulate-input (~/.local/dev/simulate-input/) package.

set -e

source ~/.local/lib/dotfiles/bash/install/rust.sh

case "$1" in
	i | u)
		install_rust_install_package --path ~/.local/dev/simulate-input
		;;

	r)
		install_rust_remove_package simulate-input
		;;
esac
