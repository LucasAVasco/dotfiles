#!/bin/bash
#
# Pnpm (https://pnpm.io/) package.

set -e

case "$1" in
	i | u)
		corepack enable
		;;
	r)
		echo 'Can not remove pnpm because it is installed by corepack' >&2
		exit 1
		;;
esac
