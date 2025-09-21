#!/bin/bash
#
# Direnv (https://direnv.net/) package.

set -e

source ../lib/wget.sh

version='v2.35.0'

case "$1" in
	i | u)
		install_wget_init
		install_wget_download "https://github.com/direnv/direnv/releases/download/$version/direnv.linux-amd64" direnv
		wget_export_files_to_bin direnv
		;;

	r)
		bin_delete_files direnv
		;;
esac
