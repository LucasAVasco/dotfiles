#!/bin/bash
#
# dagger (https://docs.dagger.io) package.

set -e

case "$1" in
	i | u)
		curl -fsSL https://dl.dagger.io/dagger/install.sh | BIN_DIR=$HOME/.local/dotfiles_bin_fallback/bin/ sh
		;;

	r)
		trash ~/.local/dotfiles_bin_fallback/bin/dagger
		;;
esac
