#!/bin/bash
#
# Dive (https://github.com/wagoodman/dive) package

set -e

source ~/.config/bash/libs/install/go.sh

case "$1" in
	i | u)
		install_go_install_package github.com/wagoodman/dive@latest
		dive completion zsh > "$HOME/.local/share/zsh_completions/_dive"
		;;

	r)
		install_go_remove_package dive
		;;
esac
