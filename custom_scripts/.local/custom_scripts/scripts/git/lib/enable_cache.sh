#!/bin/bash
#
# Function to enable the git cache and restore to the original configuration state when the script ends


declare git_helper_config=$(git config --global credential.helper)


# Restore the cache to the original state
restore_git_cache() {
	if [[ "$git_helper_config" == '' ]]; then
		git config --global --unset credential.helper
		echo -e "\nGit cache disabled..."
	fi
}


# Save the credential helper configuration and enables the cache. Add a trap to automatically restore the cache when the script ends.
# The user does not need to manually restore the cache with the 'restore_git_cache' function. THis function does notting if the cache
# is already enabled
enable_git_cache_until_end() {
	# Saves the credential helper
	git_helper_config=$(git config --global credential.helper || echo '')

	# Enables the cache
	if [[ "$git_helper_config" == '' ]]; then
		git config --global credential.helper cache
		echo -e "Git cache enabled...\n"
	fi

	# Automatically restore the cache when the script ends
	trap 'restore_git_cache' EXIT
}
