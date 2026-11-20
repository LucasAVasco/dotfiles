#!/bin/bash
#
# Antigravity CLI (https://antigravity.google/product/antigravity-cli/) package.

source ~/.local/lib/dotfiles/bash/strict.sh

AGY_BLOCK='# Added by Antigravity CLI installer
export PATH="/home/lucas_dev/.local/bin:$PATH"'

# Remove the code block automatically added by Antigravity to export '~/.local/bin/' to the PATH environment variable.
#
# $@: files to remove the export code block.
remove_agy_path_exports() {
	for file_path in "$@"; do
		if ! AGY_BLOCK="$AGY_BLOCK" perl -0777 -i -pe '
			BEGIN { $found = 0 }
			$found += s/\Q$ENV{AGY_BLOCK}\E\n?//g;
			END { exit($found ? 0 : 1) }
		' "$file_path"; then
			echo "Error: Antigravity PATH export block not found in '$file_path'." >&2
			return 1
		fi
	done
}

case "$1" in
	i | u)
		curl -fsSL https://antigravity.google/cli/install.sh | bash

		# The '~/.local/bin/' is already added to $PATH. No need to do it again. Repeating this export breaks the scripts at
		# '~/.local/dotfiles_bin_override'
		remove_agy_path_exports ~/.profile ~/.zshrc ~/.bashrc ~/.bash_profile
		;;

	r)
		rm ~/.local/bin/agy
		;;
esac
