#!/bin/bash
#
# Module to install files from Git repository in the fallback binaries directory.

source ~/.config/bash/libs/install/git.sh

# Export files from a Git repository to the fallback binaries directory.
#
# $1..n: Files to copy.
git_export_files() {
	install_git_export_files "$@" "$DOTFILES_FALLBACK_BIN/"
}
