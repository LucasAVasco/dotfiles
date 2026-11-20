#!/bin/bash
#
# Bun (https://bun.com/) package.

source ~/.local/lib/dotfiles/bash/strict.sh

case "$1" in
	i | u)
		mise use -g bun@latest
		;;

	r)
		mise unuse bun
		;;
esac
