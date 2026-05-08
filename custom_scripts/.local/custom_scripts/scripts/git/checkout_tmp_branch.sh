#!/bin/bash
#
# Checkout the current repository tho the first temporary branch found. If not found, does nothing.
#
#
# See the './lib/tmp_branch.sh' script for more information

set -e

source ./lib/tmp_branch.sh
source ~/.local/custom_scripts/libs/scripts.sh

# Runs all command in the current directory
scripts_cd_to_invoke_dir

# Temporary branch
tmp_branches_names=($(get_local_tmp_branch_name))
tmp_branch=${tmp_branches_names[0]}

# Only checkout if there is a temporary branch
if ! [[ -z "${tmp_branch}" ]]; then
	git checkout "${tmp_branch}"
fi
