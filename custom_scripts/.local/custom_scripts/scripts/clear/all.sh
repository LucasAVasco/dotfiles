#!/bin/bash
#
# Clear all non-essential data (e.g. cache, and sessions information) from the system. They are trashed instead of removed, so you can
# recover them with the 'trash-restore' command. If you want to permanently remove them, use the 'trash-empty' command after running this
# script

set -e

source ~/.local/lib/dotfiles/bash/dialog/dialog.sh
source ~/.local/lib/dotfiles/bash/markdown.sh

if [[ $(dialog_ask_boolean 'Clear all data from the system?' n) == n ]]; then
	echo 'Aborted' >&2
	exit 1
fi

# Trash files. Show the files that were trashed on stdout. Ignore errors
trash_with_debug() {
	echo ""
	echo "# Trashing $*" | markdown_format
	echo ""

	trash "$@" || true
}

# Lnav sessions
trash_with_debug ~/.config/lnav/view-info-*.json
trash_with_debug ~/.local/state/nvim/lsp.log
