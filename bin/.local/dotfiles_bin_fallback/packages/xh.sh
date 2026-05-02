#!/bin/bash
#
# xh (https://github.com/ducaale/xh) package.

set -e

source ../lib/wget.sh
source ../lib/bin.sh

version="v0.25.3"

case "$1" in
	i | u)
		install_wget_init
		install_wget_download \
			"https://github.com/ducaale/xh/releases/download/v0.25.3/xh-${version}-$(uname -m)-unknown-linux-musl.tar.gz" xh.tar.gz
		install_wget_untar_file xh.tar.gz .
		wget_export_files_to_bin "xh-${version}-$(uname -m)-unknown-linux-musl"/xh
		;;
	r)
		bin_delete_files xh
		;;
esac
