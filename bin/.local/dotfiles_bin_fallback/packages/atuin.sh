#!/bin/bash
#
# Atuin (https://atuin.sh/) package.

set -e

source ../lib/wget.sh

version=v18.8.0

case "$1" in
	i | u)
		install_wget_init

		install_wget_download https://github.com/atuinsh/atuin/releases/download/$version/atuin-x86_64-unknown-linux-gnu.tar.gz \
			atuin.tar.gz
		install_wget_untar_file atuin.tar.gz
		wget_export_files_to_bin atuin-x86_64-unknown-linux-gnu/atuin
		;;

	r)
		bin_delete_files atuin
		;;
esac
