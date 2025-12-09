#!/bin/bash
#
# Library to sync Git repositories between users.

source "$REPO_DIR/scripts/sync_folder/lib/sync_folder.sh"

sync_folder_git_remote_name='sync-folder'

# Send the '.git' folder of the current repository to the sync folder.
sync_folder_git_send_current_repo() {
	git_root=$(git rev-parse --show-toplevel)

	# Sends the '.git' folder
	trap 'clear_sync_folder' EXIT
	send_to_sync_folder "$git_root/.git"
}

# Set the remote to be used when syncing the repository between users.
#
# $1: name of the user to sync the repository.
sync_folder_git_set_remote_current_repo() {
	local user="$1"

	# Repository path
	local repo_path=$(git rev-parse --show-toplevel)
	local repo_path_relative_home=$(realpath --relative-to="$HOME" "$repo_path")

	# Remote
	local remote_url="file:///home/sync_folder/$user/$repo_path_relative_home"

	# Set the remote
	[[ $(git remote get-url $sync_folder_git_remote_name) ]] 2>/dev/null && \
		git remote set-url $sync_folder_git_remote_name "$remote_url" || \
		git remote add $sync_folder_git_remote_name "$remote_url"
}
