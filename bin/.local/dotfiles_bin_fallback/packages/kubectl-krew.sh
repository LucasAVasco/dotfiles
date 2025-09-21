#!/bin/bash
#
# kubectl-krew (https://krew.sigs.k8s.io/) package.

set -e

source ~/.config/bash/libs/install/wget.sh
source ~/.config/bash/libs/linux/arch.sh

case "$1" in
	i | u)
		install_wget_init

		# Installation
		linux_arch_arm32='arm'
		file_name=krew-linux_$(linux_arch_get)
		install_wget_download "https://github.com/kubernetes-sigs/krew/releases/latest/download/${file_name}.tar.gz" "${file_name}.tar.gz"
		install_wget_untar_file "${file_name}.tar.gz" .
		install_wget_run ./"${file_name}" install krew
		;;

	r)
		test -d ~/.krew && rm -rf -- ~/.krew || echo "Directory ~/.krew does not exist."
		;;
esac
