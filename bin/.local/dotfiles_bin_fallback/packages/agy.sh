#!/bin/bash
#
# Antigravity CLI (https://antigravity.google/product/antigravity-cli/) package.

source ~/.local/lib/dotfiles/bash/strict.sh

case "$1" in
	i | u)
		curl -fsSL https://antigravity.google/cli/install.sh | bash
		;;

	r)
		rm -f ~/.local/bin/agy
		;;
esac
