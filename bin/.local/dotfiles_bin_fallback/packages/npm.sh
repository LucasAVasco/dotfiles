#!/bin/bash
#
# Npm (https://www.npmjs.com/) package.

set -e

case "$1" in
	i | u)
		mise use --global node@latest
		;;

	r)
		echo 'Can not remove npm because it is installed by mise' >&2
		exit 1
		;;
esac
