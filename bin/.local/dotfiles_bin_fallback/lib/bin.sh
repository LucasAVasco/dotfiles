#!/bin/bash
#
# Library to manage binaries of the fallback binaries directory (../bin/).

# Copy files to the fallback binaries directory.
#
# Automatically make then executable.
#
# $1..n: Files to copy.
bin_copy_files() {
	chmod 700 "$@"
	cp "$@" "$DOTFILES_FALLBACK_BIN/"
}

# Delete files from the fallback binaries directory.
#
# $1..n: Files to delete.
bin_delete_files() {
	for file in "$@"; do
		test -f "$DOTFILES_FALLBACK_BIN/$file" && rm "$DOTFILES_FALLBACK_BIN/$file" || \
			echo "File $DOTFILES_FALLBACK_BIN/$file does not exist."
	done
}
