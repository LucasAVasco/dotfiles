#!/bin/bash
#
# jq (https://github.com/jqlang/jq) package

set -e

source ../lib/wget.sh
source ~/.local/lib/dotfiles/bash/linux/arch.sh

version='1.8.1'

case "$1" in
	i | u)
		install_wget_init
		install_wget_download "https://github.com/jqlang/jq/releases/download/jq-$version/jq-linux-$(linux_arch_get)" jq
		wget_export_files_to_bin jq
		;;

	r)
		bin_delete_files jq
		;;
esac
