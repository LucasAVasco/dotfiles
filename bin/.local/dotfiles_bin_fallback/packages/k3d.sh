#!/bin/bash
#
# K3d (https://k3d.io/) package.

set -e

source ../lib/wget.sh

version=v5.8.1

completion_file="$HOME/.local/share/zsh_completions/_k3d"

case "$1" in
	i | u)
		# Download an installation
		install_wget_init
		install_wget_download "https://github.com/k3d-io/k3d/releases/download/$version/k3d-linux-amd64" k3d
		wget_export_files_to_bin k3d

		# Completions
		k3d completion zsh > "$completion_file"
		;;

	r)
		bin_delete_files k3d
		test -f "$completion_file" && rm "$completion_file" || echo "No completions file found"
		;;
esac
