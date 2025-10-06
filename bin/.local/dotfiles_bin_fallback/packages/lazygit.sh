#!/bin/bash
#
# LazyGit (https://github.com/jesseduffield/lazygit) package.

set -e

source ../lib/wget.sh

version=0.55.1

case "$1" in
	i | u)
		install_wget_init

		install_wget_download https://github.com/jesseduffield/lazygit/releases/download/v$version/lazygit_${version}_linux_x86_64.tar.gz \
			download.tar.gz
		install_wget_untar_file download.tar.gz
		wget_export_files_to_bin lazygit
		;;

	r)
		bin_delete_files lazygit
		;;
esac
