#!/bin/bash
#
# Install Gum (https://github.com/charmbracelet/gum).

set -e

source ~/.config/bash/libs/install/go.sh

version='latest'
completion_file="$HOME/.local/share/zsh_completions/_gum"

case "$1" in
	i | u)
		install_go_install_package "github.com/charmbracelet/gum@$version"
		gum completion zsh > "$completion_file"
		;;

	r)
		install_go_remove_package gum
		test -f "$completion_file" && rm "$completion_file" || echo "No completions file found"
		;;
esac
