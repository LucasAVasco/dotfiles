#!/bin/bash
#
# Navi (https://github.com/denisidoro/navi) package

set -e

source ../lib/wget.sh

version='v2.24.0'

case "$1" in
	i | u)
		install_wget_init

		install_wget_download \
			https://github.com/denisidoro/navi/releases/download/$version/navi-${version}-x86_64-unknown-linux-musl.tar.gz \
			navi.tar.gz
		install_wget_untar_file navi.tar.gz .
		wget_export_files_to_bin navi
		;;

	r)
		bin_delete_files navi
		;;
esac
