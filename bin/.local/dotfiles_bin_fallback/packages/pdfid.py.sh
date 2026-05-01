#!/bin/bash
#
# pdfid.py (https://gitlab.com/kalilinux/packages/pdfid) package.

set -e

source ../lib/wget.sh
source ../lib/bin.sh

case "$1" in
	i | u)
		install_wget_init
		install_wget_download https://gitlab.com/kalilinux/packages/pdfid/-/raw/kali/master/pdfid.py ./pdfid.py
		wget_export_files_to_bin pdfid.py
		;;
	r)
		bin_delete_files pdfid.py
		;;
esac
