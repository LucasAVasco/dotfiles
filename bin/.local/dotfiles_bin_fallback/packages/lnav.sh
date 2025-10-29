#!/bin/bash
#
# 'lnav' (https://lnav.org/) package.

set -e

source ../lib/wget.sh
source ../lib/bin.sh

version="0.13.2"

case "$1" in
	i | u)
		install_wget_init
		install_wget_download "https://github.com/tstack/lnav/releases/download/v$version/lnav-${version}-linux-musl-x86_64.zip" lnav.zip
		install_wget_unzip_file lnav.zip .
		wget_export_files_to_bin "lnav-$version/lnav"
		;;
	r)
		bin_delete_files lnav
		;;
esac
