#!/bin/bash
#
# cobra-cli (github.com/spf13/cobra@latest) package.

set -e

source ~/.config/bash/libs/install/go.sh

version=latest

case "$1" in
	i | u)
		install_go_install_package "github.com/spf13/cobra-cli@$version"
		;;

	r)
		install_go_remove_package cobra-cli
		;;
esac
