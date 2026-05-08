#!/bin/bash
#
# Clone a repository from another user. The cloned repository will be inside the current working directory.

set -e

source ./lib/sync_repo.sh
source ~/.local/custom_scripts/libs/scripts.sh

# Runs all command in the current directory
scripts_cd_to_invoke_dir

# Selects the user to clone the repository from
user_to_copy=$(cd "$SYNC_FOLDER" && find -maxdepth 1 -regex './\w*' -type d | fzf)

# Selects the repository
repository_to_clone=$(cd "$SYNC_FOLDER/$user_to_copy" && find -type d -name '.git' | fzf)
repository_to_clone=$(realpath "$SYNC_FOLDER/$user_to_copy/$repository_to_clone") # Absolute path
repository_to_clone="file://$repository_to_clone" # URL

# Clones inside the current directory
git clone --origin="$sync_folder_git_remote_name" "$repository_to_clone"
