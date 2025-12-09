#!/bin/bash
#
# Fetch the current repository from another user.

set -e

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
source "$current_dir/lib/sync_repo.sh"

# Select the user to fetch
user_to_copy=$(cd "$SYNC_FOLDER" && find -maxdepth 1 -regex './\w*' -type d | fzf)

if [[ -z "$user_to_copy" ]]; then
	echo 'User to copy not provided. Aborting'
	exit 1
fi

# Uses the current repository
cd "$WORKING_DIR"

sync_folder_git_set_remote_current_repo "$user_to_copy"
git fetch "$sync_folder_git_remote_name"
