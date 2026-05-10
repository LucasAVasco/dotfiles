#!/bin/bash
#
# Library to manage dotfiles fallback binaries.

# Access the dotfiles fallback installer manager.
#
# $@: Arguments passed to the manager.
bin_fallback_manager() {
	~/.local/dotfiles_bin_fallback/manager.sh "$@"
}
