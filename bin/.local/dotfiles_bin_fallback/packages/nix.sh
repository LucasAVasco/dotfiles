#!/bin/bash
#
# nix (https://nixos.org/) package

set -e

source ../lib/bin.sh

case "$1" in
	i | u)
		~/.local/dev/rootless-nix/build.sh
		for file in ~/.local/dev/rootless-nix/bin/*; do
			bin_copy_files "$file"
		done
		;;

	r)
		for file in ~/.local/dev/rootless-nix/bin/*; do
			filename=$(basename "$file")
			bin_delete_files "$filename"
		done
		;;
esac
