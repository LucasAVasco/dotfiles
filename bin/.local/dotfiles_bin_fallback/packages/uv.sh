#!/bin/bash
#
# UV (https://github.com/astral-sh/uv) package.

set -e

source ../lib/pip.sh

case "$1" in
	i | u)
		pip_install_package uv uv
		;;

	r)
		pip_remove_package uv uv
		;;
esac
