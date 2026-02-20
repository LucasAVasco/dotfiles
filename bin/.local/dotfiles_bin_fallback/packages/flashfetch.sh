#!/bin/bash
#
# Fastfetch and Flashfetch (https://github.com/fastfetch-cli/fastfetch) package.

set -e

version='2.58.0'

case "$1" in
	i )
		../manager.sh install fastfetch
		;;

	u)
		../manager.sh update fastfetch
		;;

	r)
		../manager.sh uninstall fastfetch
		;;
esac
