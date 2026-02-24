#!/bin/bash

# Checks if a branch exists in the current repository
#
# $1: The name of the branch
git_has_branch() {
	local branch_name="$1"

	if git rev-parse --verify --quiet "$branch_name" > /dev/null 2>&1; then
		echo -n y
	else
		echo -n n
	fi
}
