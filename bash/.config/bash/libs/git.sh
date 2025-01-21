#!/bin/bash
#
# Utilities functions to manage Git repositories.

# Get the last version from the repository tags.
#
# Do not clone the repository.
#
# $1: repository URL
# Return a string with the latest repository version.
git_get_last_version_tag() {
	local repo_url="$1"
	git ls-remote --tags "$repo_url" | sed 's/^.*\///g' | tail -1
}
