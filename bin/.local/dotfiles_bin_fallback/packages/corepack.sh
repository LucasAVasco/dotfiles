#!/bin/bash
#
# corepack (https://github.com/nodejs/corepack) package.

set -e

source ../lib/wget.sh
source ../lib/bin.sh

case "$1" in
	i | u)
		npm install -g corepack
		;;

	r)
		npm uninstall -g corepack
		;;
esac
