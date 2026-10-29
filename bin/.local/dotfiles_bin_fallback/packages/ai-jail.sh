#!/bin/bash
#
# ai-jail (https://github.com/akitaonrails/ai-jail) package.

set -e

source ~/.local/lib/dotfiles/bash/install/rust.sh

case "$1" in
	i | u)
		install_rust_install_package ai-jail
		;;

	r)
		install_rust_remove_package ai-jail
		;;
esac
