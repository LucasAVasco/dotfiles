#!/bin/bash
#
# pdf-parser.py (https://gitlab.com/kalilinux/packages/pdf-parser) package.

set -e

source ../lib/wget.sh
source ../lib/bin.sh

case "$1" in
	i | u)
		install_wget_init
		install_wget_download https://gitlab.com/kalilinux/packages/pdf-parser/-/raw/kali/master/pdf-parser.py ./pdf-parser.py
		wget_export_files_to_bin pdf-parser.py
		;;
	r)
		bin_delete_files pdf-parser.py
		;;
esac
