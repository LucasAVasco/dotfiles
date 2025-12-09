#!/bin/bash
#
# Clear the user sync folder.

set -e

current_dir=$(realpath -m -- "${BASH_SOURCE[0]}/../")
source "$current_dir/lib/sync_folder.sh"

source "$REPO_DIR/libs/tui.sh"

if [[ $(tui_ask_boolean "Want to clear the your content inside the sync folder?" 'n') == 'y' ]]; then
	clear_sync_folder
else
	echo 'Operation aborted...' >&2
	exit 1
fi
