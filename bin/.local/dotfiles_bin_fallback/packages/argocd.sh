#!/bin/bash
#
# Argo CD (https://argo-cd.readthedocs.io/en/stable/) package.

set -e

source ../lib/wget.sh
source ../lib/bin.sh

version='v2.14.5'

case "$1" in
	i | u)
		install_wget_init
		install_wget_download "https://github.com/argoproj/argo-cd/releases/download/$version/argocd-linux-amd64" argocd
		wget_export_files_to_bin argocd
		;;
	r)
		bin_delete_files argocd
		;;
esac
