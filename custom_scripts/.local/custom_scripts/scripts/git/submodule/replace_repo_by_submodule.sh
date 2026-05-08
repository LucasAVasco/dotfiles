#!/bin/bash
#
# Change the current repository by a sub module.
#
# Creates a sub module in the parent folder with the same origin as the current. The current repository will be backup to a
# temporary folder with the name: '<current folder name>.tmp_repo/' before the sub module is created

set -e

source ~/.local/custom_scripts/libs/scripts.sh

# Runs all command in the current directory
scripts_cd_to_invoke_dir

remote_url=$(git remote get-url origin)
dir_name=$(basename "$PWD")
top_working_dir=$(realpath -m -- "$PWD/../")
backup_repository="${top_working_dir}/${dir_name}.tmp_repo"

# Go to the top directory. Can not be in the folder to rename it
cd "$top_working_dir"

# Does not work if a temporary folder already exists. The user need to manually delete it before running the script
if [[ -d "$backup_repository" ]]; then
	echo "'$backup_repository/' already exists. Aborting..."
	exit 1
fi

# Moves the repository to a temporary folder and creates the sub module
mv "$scripts_invoke_dir" "$backup_repository"
git submodule add "$remote_url" "$dir_name" # Automatically fetches all branches of the remote. The user does not need fetch manually
