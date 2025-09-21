#!/bin/bash
#
# AppImageLauncher (https://github.com/TheAssassin/AppImageLauncher/) package.

set -e

source ../lib/wget.sh
source ../lib/bin.sh

case "$1" in
	i | u)
		install_wget_init
		install_wget_download https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher-lite-2.2.0-travis995-0f91801-x86_64.AppImage appimagelauncher-lite
		wget_export_files_to_bin appimagelauncher-lite
		;;
	r)
		bin_delete_files appimagelauncher-lite
		;;
esac
