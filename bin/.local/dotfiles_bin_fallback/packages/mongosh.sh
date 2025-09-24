#!/bin/bash
#
# `mongosh` (https://www.mongodb.com/try/download/shell) package.

set -e

source ../lib/wget.sh

version="2.5.7"
arch="x64"

case "$1" in
	i | u)
		install_wget_init

		# Download
		file_stub="mongosh-${version}-linux-${arch}"
		install_wget_download "https://downloads.mongodb.com/compass/${file_stub}.tgz" mongo.tgz

		# Extraction and installation
		install_wget_untar_file mongo.tgz mongo
		wget_export_files_to_bin mongo/${file_stub}/bin/mongosh
		;;

	r)
		bin_delete_files mongosh
		;;
esac
