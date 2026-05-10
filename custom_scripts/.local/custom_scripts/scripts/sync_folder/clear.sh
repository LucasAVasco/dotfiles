#!/bin/bash
#
# Clear the user sync folder.

set -e

source ./lib/sync_folder.sh
source ~/.local/lib/dotfiles/bash/dialog/dialog.sh
source ~/.local/custom_scripts/libs/scripts.sh

# Runs all command in the current directory
scripts_cd_to_invoke_dir

# Asks if the user want to clear the sync folder
if [[ $(dialog_ask_boolean "Want to clear the your content inside the sync folder?" 'n') == 'n' ]]; then
	echo 'Operation aborted...' >&2
	exit 1
fi

clear_sync_folder
