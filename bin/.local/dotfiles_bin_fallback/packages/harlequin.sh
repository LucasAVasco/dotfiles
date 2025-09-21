#!/bin/bash
#
# Harlequin (https://harlequin.sh/) package.

set -e

source ~/.config/bash/libs/install/uv.sh

case "$1" in
	i | u)
		install_uv_install_tool harlequin
		;;

	r)
		install_uv_remove_tool harlequin
		;;
esac
