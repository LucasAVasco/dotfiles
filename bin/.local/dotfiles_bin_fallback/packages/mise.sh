#!/bin/bash
#
# Installs `mise` (https://mise.jdx.dev/)

set -e

completions_file="$HOME/.local/share/zsh_completions/_mise"

case "$1" in
	i | u)
		# Main command installation
		curl https://mise.run | sh

		# Completions
		~/.local/bin/mise completion zsh > "$completions_file"
		;;

	r)
		# Removing Mise and its data
		test -f ~/.local/bin/mise && mise implode || true

		# Removing completions
		test -f "$completions_file" && rm "$completions_file" || echo "No completions file found"
		;;
esac
