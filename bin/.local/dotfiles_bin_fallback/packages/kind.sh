#!/bin/bash
#
# Kind (https://kind.sigs.k8s.io/) package.

set -e

source ~/.config/bash/libs/install/go.sh

version='v0.25.0'

completion_file="$HOME/.local/share/zsh_completions/_kind"

case "$1" in
	i | u)
		install_go_install_package "sigs.k8s.io/kind@$version"
		kind completion zsh > "$completion_file"
		;;

	r)
		install_go_remove_package kind
		test -f "$completion_file" && rm "$completion_file" || echo "No completions file found"
		;;
esac
