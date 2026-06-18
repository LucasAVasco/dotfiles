#!/bin/bash
#
# Forcefully pull the current repository from another user.

set -e

source ./lib/sync_repo.sh
source ~/.local/custom_scripts/libs/scripts.sh
source ~/.local/lib/dotfiles/bash/dialog/dialog.sh

# Runs all command in the current directory
scripts_cd_to_invoke_dir

# Select the user to pull
user_to_copy=$(cd "$SYNC_FOLDER" && find -maxdepth 1 -regex './\w*' -type d | fzf)

if [[ -z "$user_to_copy" ]]; then
	echo 'User to copy not provided. Aborting'
	exit 1
fi

remote=$(sync_folder_git_set_remote_current_repo "$user_to_copy")
git fetch "$remote"
if [[ $(dialog_ask_boolean "Force pull?" 'n') == 'n' ]]; then
	echo 'Operation aborted...' >&2
	exit 1
fi
git reset --hard "$remote"/main
