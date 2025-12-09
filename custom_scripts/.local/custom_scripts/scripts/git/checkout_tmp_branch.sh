#!/bin/bash
#
# Checkout the current repository tho the first temporary branch found. If not found, does nothing.
#
#
# See the 'lib/tmp_branch.sh' script for more information


set -e


current_dir=$(realpath -m -- "$0/../")
source "${current_dir}/lib/tmp_branch.sh"


tmp_branches_names=($(get_local_tmp_branch_name))
tmp_branch=${tmp_branches_names[0]}


# Only checkout if there is a temporary branch
if ! [[ -z "${tmp_branch}" ]]; then
	git checkout "${tmp_branch}"
fi
