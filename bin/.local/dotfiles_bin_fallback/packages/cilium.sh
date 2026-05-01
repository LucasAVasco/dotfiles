#!/bin/bash
#
# Cilium (https://cilium.io/) package.

set -e

source ../lib/wget.sh
source ~/.config/bash/libs/linux/arch.sh

version='v0.19.2'

case "$1" in
	i | u)
		install_wget_init
		install_wget_cd .

		# Based on https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli
		arch=$(linux_arch_get)
		curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/$version/cilium-linux-${arch}.tar.gz{,.sha256sum}
		sha256sum --check cilium-linux-${arch}.tar.gz.sha256sum
		install_wget_untar_file cilium-linux-${arch}.tar.gz
		wget_export_files_to_bin cilium
		rm cilium-linux-${arch}.tar.gz{,.sha256sum}
		;;

	r)
		bin_delete_files cilium
		;;
esac
