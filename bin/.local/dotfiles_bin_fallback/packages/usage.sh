#!/bin/bash
#
# 'usage-cli' (https://usage.jdx.dev/) package.

set -e

source ~/.config/bash/libs/install/rust.sh

case "$1" in
	i | u)
		install_rust_install_package usage-cli
		;;

	r)
		install_rust_remove_package usage-cli
		;;
esac
