#!/bin/bash
#
# ASDF (https://asdf-vm.com/) package.

set -e

source ~/.config/bash/libs/install/go.sh

install_dir=~/.asdf
version="v0.18.0"

completion_file="$HOME/.asdf/completions/_asdf"

case "$1" in
	i | u)
		# Installs ASDF
		install_go_install_package github.com/asdf-vm/asdf/cmd/asdf@"$version"

		# Completion files installation
		mkdir -p "$HOME/.asdf/completions"
		asdf completion zsh > "$completion_file"
		;;

	r)
		install_go_remove_package asdf

		test -f "$completion_file" && rm "$completion_file" || echo "No completions file found"
		;;
esac
