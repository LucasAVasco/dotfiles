#!/bin/bash
#
# Library to work with the sync folder.

SYNC_FOLDER=/home/sync_folder
SYNC_FOLDER_OF_USER="$SYNC_FOLDER/$USER"

# Copies the content of the sync folder to the user home.
sync_folder_apply() {
	trap 'chmod 700 "$HOME"' EXIT

	# TODO(LucasAVasco): Something is changing my '$HOME' permissions to be equal to the sync folder. Check if this function is the cause
	rsync -a "$SYNC_FOLDER/$1/" "$HOME/"
}

# Copies the content of the user home to the sync folder.
send_to_sync_folder() {
	local file="$1"

	# The `file` variable should be the file or folder to transfer relative to the user home directory
	if [[ "${file:0:1}" != '/' ]]; then
		file="$PWD/$file"
	fi
	file=$(realpath --relative-to="$HOME" "$file")

	local parent_dir=$(dirname "$file")
	mkdir -p "$SYNC_FOLDER_OF_USER/$parent_dir"
	rsync -a --delete --delete-excluded "$HOME/$file" "$SYNC_FOLDER_OF_USER/$parent_dir"
	chmod u=rwX,g=rX,o= -R "$SYNC_FOLDER_OF_USER"
	chgrp sync_folder -R "$SYNC_FOLDER_OF_USER"
}

# Clear the user sync folder.
clear_sync_folder() {
	trash "$SYNC_FOLDER_OF_USER"
	echo "Clearing sync folder at '$SYNC_FOLDER_OF_USER'"
	echo -e "\x1b[1;33mNOTE: the sync folder was trashed instead of removed.\nUse \`trash-empty\` to remove the trashed files.\x1b[0m"
}
