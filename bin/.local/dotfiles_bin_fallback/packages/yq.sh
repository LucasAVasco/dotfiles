#!/bin/bash
#
# Yq (https://github.com/mikefarah/yq) package.

set -e

source ~/.config/bash/libs/install/go.sh

case "$1" in
	i | u)
		install_go_install_package github.com/mikefarah/yq/v4@latest
		;;

	r)
		install_go_remove_package yq
		;;
esac
