#!/bin/bash
#
# Commitizen (https://github.com/commitizen-tools/commitizen) package.

set -e

source ~/.local/lib/dotfiles/bash/install/uv.sh

case "$1" in
	i | u)
		install_uv_install_tool commitizen
		;;

	r)
		install_uv_remove_tool commitizen
		;;
esac
