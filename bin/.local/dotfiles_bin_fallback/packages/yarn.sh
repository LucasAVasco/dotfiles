#!/bin/bash
#
# Yarn (https://github.com/yarnpkg/berry) package.

set -e

case "$1" in
	i | u)
		npm install -g corepack
		corepack enable
		;;
	r)
		echo 'Can not remove Yarn because it is installed by corepack' >&2
		exit 1
		;;
esac
