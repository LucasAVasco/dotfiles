#!/bin/bash
#
# Install Glow (https://github.com/charmbracelet/glow).

set -e

source ~/.config/bash/libs/install/go.sh

version='latest'

case "$1" in
	i | u)
		install_go_install_package "github.com/charmbracelet/glow@$version"
		;;

	r)
		install_go_remove_package glow
		;;
esac
