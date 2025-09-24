#!/bin/bash
#
# Atuin (https://atuin.sh/) package.

set -e

source ~/.config/bash/libs/install/rust.sh

case "$1" in
	i | u)
		install_rust_install_package atuin
		;;

	r)
		install_rust_remove_package atuin
		;;
esac
