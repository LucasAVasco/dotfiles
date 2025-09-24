#!/bin/bash
#
# Ninja (https://github.com/ninja-build/ninja/) package.

set -e

source ../lib/wget.sh

version='v1.13.0'

case "$1" in
	i | u)
		install_wget_init

		install_wget_download "https://github.com/ninja-build/ninja/releases/download/$version/ninja-linux.zip" ninja.zip
		install_wget_unzip_file ninja.zip
		wget_export_files_to_bin ninja
		;;

	r)
		bin_delete_files ninja
		;;
esac
