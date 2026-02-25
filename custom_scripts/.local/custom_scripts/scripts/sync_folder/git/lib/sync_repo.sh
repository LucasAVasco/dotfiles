#!/bin/bash
#
# Library to sync Git repositories between users.

source "$REPO_DIR/scripts/sync_folder/lib/sync_folder.sh"

source ~/.config/bash/libs/git/remote.sh

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
#
# Return the name of the configured remote.
sync_folder_git_set_remote_current_repo() {
	local user="$1"

	# Repository path
	local repo_path=$(git rev-parse --show-toplevel)
	local repo_path_relative_home=$(realpath --relative-to="$HOME" "$repo_path")
	local dest_folder="$(realpath -m "/home/sync_folder/$user/$repo_path_relative_home")"

	# Remote
	local remote_url="file://$dest_folder"

	# Tries to set the origin remote
	if [[ $(git_remote_has origin) == n ]]; then
		git remote add origin "$remote_url"
		echo origin
		return
	fi

	if [[ "$(git remote get-url origin)" == "$remote_url" ]]; then
		echo origin
		return
	fi

	# Set the sync-folder remote
	if [[ $(git_remote_has "$sync_folder_git_remote_name") == y ]]; then
		git remote set-url $sync_folder_git_remote_name "$remote_url"
	else
		git remote add $sync_folder_git_remote_name "$remote_url"
	fi

	echo "$sync_folder_git_remote_name"
}
