#!/bin/bash
#
# Library to download files in the fallback binaries directory with Wget for Bash.
#
# You must call the `wget_init()` function before any other function.

source ~/.config/bash/libs/install/wget.sh

source "$DOTFILES_FALLBACK_LIBS/bin.sh"

# Export files from the download directory to the local 'bin/' directory used by fallback installer scripts.
#
# $1..n: Files to export.
wget_export_files_to_bin() {
	local -a abs_files

	for file_path in "$@"; do
		abs_files+="$(install_wget_get_abs_path "$file_path")"
	done

	bin_copy_files "${abs_files[@]}"
}
