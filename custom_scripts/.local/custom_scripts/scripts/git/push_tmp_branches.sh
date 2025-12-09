#!/bin/bash
#
#
# Push all temporary branches of the current repository to the temporary remote
# If this remote does not exist, it will be created based in the 'origin' remote (asks if the user wants to create it)
#
# See the 'lib/tmp_branch.sh' script for more information


set -e


current_dir=$(realpath -m -- "$0/../")
source "${current_dir}/lib/tmp_branch.sh"


# Only push if there is at least one temporary branch
if [[ $(there_is_local_tmp_branch) == 'true' ]]; then
	# If there is not the temporary remote, create it. Uses the URL of the origin
	git remote get-url $tmp_remote_name > /dev/null 2>&1 || {
		read -r -p "Create a temporary remote based in the 'origin' remote? [y/N] " user_response

		if [[ "$user_response" =~ ^[yY]$ ]]; then
			git remote add "$tmp_remote_name" $(git remote get-url origin)
		fi
	}

	# Pushes all local temporary branches to the temporary remote
	git push my_tmp_repo $(get_local_tmp_branch_name)
fi
