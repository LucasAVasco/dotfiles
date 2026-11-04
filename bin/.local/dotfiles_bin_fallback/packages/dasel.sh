#!/bin/bash
#
# Dasel (https://github.com/tomwright/dasel) package

set -e

source ~/.local/lib/dotfiles/bash/install/go.sh

case "$1" in
	i | u)
		install_go_install_package github.com/tomwright/dasel/v3/cmd/dasel@master
		dasel completion zsh > "$HOME/.local/share/zsh_completions/_dasel"
		;;

	r)
		install_go_remove_package dasel
		;;
esac
