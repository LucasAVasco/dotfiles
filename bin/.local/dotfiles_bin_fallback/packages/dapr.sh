#!/bin/bash
#
# Dapr (https://docs.dapr.io/) package.

set -e

source ../lib/bin.sh

case "$1" in
	i | u)
		wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | \
			DAPR_INSTALL_DIR="$HOME/.local/dotfiles_bin_fallback/bin/" bash
		;;

	r)
		bin_delete_files dapr
		;;
esac
