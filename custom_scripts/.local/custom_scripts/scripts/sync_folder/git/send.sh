#!/bin/bash
#
# Send the current repository to another user.

set -e

source ./lib/sync_repo.sh
source ~/.local/custom_scripts/libs/scripts.sh

# Runs all command in the current directory
scripts_cd_to_invoke_dir

# Uses the current repository
sync_folder_git_send_current_repo

# Wait by the user
echo 'Press enter to end the send procedure'
read
