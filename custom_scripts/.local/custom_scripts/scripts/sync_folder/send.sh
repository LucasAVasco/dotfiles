#!/bin/bash
#
# Send some folder in the current directory to the sync folder.

set -e

current_dir=$(realpath -m -- "${BASH_SOURCE[0]}/../")
source "$current_dir/lib/sync_folder.sh"

# Query the folder to send
folder_to_send=$(find -maxdepth 3 -type f -or -type d | fzf)

if [[ -z "$folder_to_send" ]]; then
	echo 'File not provided. Aborting...'
	exit 1
fi

# Send the folder
trap 'clear_sync_folder' EXIT
send_to_sync_folder "$folder_to_send"

# Wait for the user
echo 'Press enter to end the transfer procedure'
read
