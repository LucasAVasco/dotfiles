#!/bin/bash
#
# DevPod (https://devpod.sh/) package

set -e

source ../lib/wget.sh

case "$1" in
	i | u)
		install_wget_init

		install_wget_download https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64 devpod
		wget_export_files_to_bin devpod
		devpod completion zsh > ~/.local/share/zsh_completions/_devpod
		;;

	r)
		bin_delete_files devpod
		;;
esac
