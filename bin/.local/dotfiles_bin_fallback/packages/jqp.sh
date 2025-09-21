#!/bin/bash
#
# jqp (https://github.com/noahgorstein/jqp) package.

set -e

source ~/.config/bash/libs/install/go.sh

version=latest

case "$1" in
	i | u)
		install_go_install_package "github.com/noahgorstein/jqp@$version"
		;;

	r)
		install_go_remove_package jqp
		;;
esac
