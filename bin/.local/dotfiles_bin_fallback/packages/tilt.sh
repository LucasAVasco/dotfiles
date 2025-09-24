#!/bin/bash
#
# Tilt (https://tilt.dev/) package.

set -e

completion_file="$HOME/.local/share/zsh_completions/_tilt"

case "$1" in
	i | u)
		# Copied from https://docs.tilt.dev/install.html
		curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
		tilt completion zsh > "$completion_file"
		;;

	r)
		test -f ~/.local/bin/tilt && rm ~/.local/bin/tilt || echo "Tilt is not installed"
		test -f "$completion_file" && rm "$completion_file" || echo "No completions file found"
		;;
esac
