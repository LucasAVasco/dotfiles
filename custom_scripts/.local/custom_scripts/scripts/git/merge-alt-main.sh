#!/bin/bash
#
# Git does not support pushing changes to a local repository (file system) if the target is checkout in the 'main' branch. The user must
# checkout the target repository to another branch before pushing the changes
#
# This script creates a branch called 'alt_main.doNotUse' if it does not exist and checkouts to it. Now the user can push the changes to
# this repository
#
# It also merges the 'alt_main.doNotUse' branch with the 'main' branch to synchronize them

set -e

source ~/.local/custom_scripts/libs/scripts.sh
source ~/.local/custom_scripts/scripts/git/lib/branch.sh

branch='alt_main.doNotUse'

# Runs all command in the current directory
scripts_cd_to_invoke_dir

# Ensures the branch exists
if [[ "$(git_has_branch "$branch")" == n ]]; then
	scripts_log_info 'Creating branch'
	git branch "$branch"
fi

# Merges the alternative branch with the 'main' branch
scripts_log_info 'Merging branch with main'
git checkout "$branch"
git merge --ff-only main
