#!/bin/bash
#
# Send the current repository to another user.

set -e

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
source "$current_dir/lib/sync_repo.sh"

# Uses the current repository
cd "$WORKING_DIR"
sync_folder_git_send_current_repo

# Wait by the user
echo 'Press enter to end the send procedure'
read
