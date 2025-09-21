#!/bin/bash
#
# Act (https://github.com/nektos/act/) package.

set -e

source ../lib/wget.sh
source ../lib/bin.sh

case "$1" in
	i | u)
		install_wget_init
		install_wget_download https://github.com/nektos/act/releases/latest/download/act_Linux_x86_64.tar.gz act.tar.gz
		install_wget_untar_file act.tar.gz .
		wget_export_files_to_bin act
		;;
	r)
		bin_delete_files act
		;;
esac
