#!/bin/bash
#
# Kompose (https://kompose.io/) package.

set -e

version='v1.38.0'

source ../lib/wget.sh
source ~/.local/lib/dotfiles/bash/linux/arch.sh

case "$1" in
	i | u)
		install_wget_init
		install_wget_download "https://github.com/kubernetes/kompose/releases/download/$version/kompose-linux-$(linux_arch_get)" 'kompose'
		wget_export_files_to_bin kompose
		;;

	r)
		bin_delete_files kompose
		;;
esac
