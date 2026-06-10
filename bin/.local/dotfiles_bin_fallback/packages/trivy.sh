#!/bin/bash
#
# trivy (https://github.com/aquasecurity/trivy/) package

set -e

source ../lib/wget.sh

version='0.71.0'

case "$1" in
	i | u)
		install_wget_init
		install_wget_download \
			"https://github.com/aquasecurity/trivy/releases/download/v$version/trivy_${version}_Linux-64bit.tar.gz" trivy.tar.gz
		install_wget_untar_file trivy.tar.gz trivy-untar
		wget_export_files_to_bin trivy-untar/trivy
		;;

	r)
		bin_delete_files trivy
		;;
esac
