#!/bin/bash
#
# Falcula (https://github.com/LucasAVasco/falcula/) package

set -e

source ~/.local/lib/dotfiles/bash/install/go.sh

case "$1" in
	i | u)
		install_go_install_package github.com/LucasAVasco/falcula/cmd/falcula@latest
		falcula completion zsh > "$HOME/.local/share/zsh_completions/_falcula"
		;;

	r)
		install_go_remove_package falcula
		;;
esac
