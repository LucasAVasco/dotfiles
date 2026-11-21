#!/bin/bash
#
# Lefthook (https://lefthook.dev/) package.

set -e

case "$1" in
	i | u)
		mise use -g lefthook@latest
		;;

	r)
		mise unuse lefthook
		;;
esac
