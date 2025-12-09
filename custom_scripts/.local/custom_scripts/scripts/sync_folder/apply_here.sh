#!/bin/bash
#
# Receive files sent by another user in the current user home. Example, if the 'user1' send the '~/.config/conf1' folder to the sync folder,
# this script will copy the '.config/conf1' folder of the 'user1' and apply it to the current user (apply the differences to
# '~/.config/conf1').

set -e

current_dir=$(realpath -m -- "$0/../")
source "$current_dir/lib/sync_folder.sh"

source "$REPO_DIR/libs/tui.sh"

# Query the folder to apply
cd "$SYNC_FOLDER"
user_to_copy=$(find -maxdepth 1 -regex './\w*' -type d | fzf)

if [[ -z "$user_to_copy" ]]; then
	echo 'User to copy not provided. Aborting'
	exit 1
fi

# Show the files to be received
if [[ -f '/bin/eza' ]]; then
	eza -T --icons=always --color=always --all --tree --ignore-glob='.git' "$SYNC_FOLDER/$user_to_copy" | less -r

else
	find "$SYNC_FOLDER/$user_to_copy" | less
fi

# Sends the content to a folder with the user name inside the sync folder
if [[ $(tui_ask_boolean "Want to apply the modifications of the '$user_to_copy' user in the current 'HOME'?" 'n') == 'n' ]]; then
	echo -e '\nOperation aborted...' >&2
	exit 1
fi

# Apply the content
sync_folder_apply "$user_to_copy"
