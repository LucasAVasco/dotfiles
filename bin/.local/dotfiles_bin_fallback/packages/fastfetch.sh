#!/bin/bash
#
# Fastfetch and Flashfetch (https://github.com/fastfetch-cli/fastfetch) package.

set -e

source ../lib/wget.sh
source ../lib/bin.sh
source ~/.config/bash/libs/linux/arch.sh

version='2.58.0'

case "$1" in
	i | u)
		install_wget_init
		install_wget_download \
			"https://github.com/fastfetch-cli/fastfetch/releases/download/$version/fastfetch-linux-$(linux_arch_get).tar.gz" \
			fastfetch.tar.gz
		install_wget_untar_file fastfetch.tar.gz .
		install_wget_mv "fastfetch-linux-$(linux_arch_get)/usr/bin/fastfetch" fastfetch
		install_wget_mv "fastfetch-linux-$(linux_arch_get)/usr/bin/flashfetch" flashfetch
		install_wget_list_files .
		wget_export_files_to_bin fastfetch flashfetch
		;;

	r)
		bin_delete_files fastfetch flashfetch
		;;
esac
