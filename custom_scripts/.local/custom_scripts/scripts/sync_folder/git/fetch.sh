#!/bin/bash
#
# Fetch the current repository from another user.

set -e

source ./lib/sync_repo.sh
source ~/.local/custom_scripts/libs/scripts.sh

# Runs all command in the current directory
scripts_cd_to_invoke_dir

# Select the user to fetch
user_to_copy=$(cd "$SYNC_FOLDER" && find -maxdepth 1 -regex './\w*' -type d | fzf)

if [[ -z "$user_to_copy" ]]; then
	echo 'User to copy not provided. Aborting'
	exit 1
fi

remote=$(sync_folder_git_set_remote_current_repo "$user_to_copy")
git fetch "$remote"
