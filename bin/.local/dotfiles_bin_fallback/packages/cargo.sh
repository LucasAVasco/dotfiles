#!/bin/bash
#
# Cargo (https://github.com/rust-lang/cargo) package.

source ~/.local/lib/dotfiles/bash/strict.sh

source ~/.local/lib/dotfiles/bash/install/mise.sh

case "$1" in
	i | u)
		install_mise_install_package 'rust@latest'
		;;

	r)
		install_mise_remove_package 'rust@latest'
		trash ~/.rustup/toolchains/* || true
		trash ~/.rustup/downloads/* || true
		trash ~/.rustup/tmp/* || true
		;;
esac
