#!/bin/bash
#
# Conan (https://conan.io/) package.

set -e

source ~/.config/bash/libs/install/uv.sh

case "$1" in
	i | u)
		install_uv_install_tool conan
		;;

	r)
		install_uv_remove_tool conan
		;;
esac
