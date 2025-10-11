#!/bin/bash
#
# Websocat (https://github.com/vi/websocat) package.

set -e

source ../lib/wget.sh

version=4.0.0-alpha2

case "$1" in
	i | u)
		install_wget_init

		install_wget_download \
			https://github.com/vi/websocat/releases/download/v$version/websocat.x86_64-unknown-linux-musl \
			websocat
		wget_export_files_to_bin websocat
		;;

	r)
		bin_delete_files websocat
		;;
esac
