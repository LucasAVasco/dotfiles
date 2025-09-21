#!/bin/bash
#
# Dotenvc (https://dotenvx.com/) package.

set -e

source ../lib/wget.sh

version='latest'

case "$1" in
	i | u)
		install_wget_init
		install_wget_download "https://github.com/dotenvx/dotenvx/releases/$version/download/dotenvx-$(uname -s)-$(uname -m).tar.gz" \
			dotenvx.tar.gz
		install_wget_untar_file dotenvx.tar.gz dotenvx-untar
		wget_export_files_to_bin dotenvx-untar/dotenvx
		;;

	r)
		bin_delete_files dotenvx
		;;
esac
