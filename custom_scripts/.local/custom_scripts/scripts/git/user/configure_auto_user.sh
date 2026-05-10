#!/bin/bash
#
# Configure the current repository to use a default user name for all remotes.

set -e

source ./lib/remotes.sh
source ~/.local/lib/dotfiles/bash/dialog/dialog.sh
source ~/.local/custom_scripts/libs/scripts.sh

# Runs all command in the current directory
scripts_cd_to_invoke_dir

# Interactively set the user of some remotes.
#
# $1: The user name.
# $2+: The names of the remotes.
set_user_of_remotes() {
	local user_name="$1"

	for remote_name in "${@:2}"; do
		local old_url=$(git_get_remote_url "$remote_name")
		local new_url=''

		if [[ "$old_url" =~ .*@.* ]]; then # Already has a user configured
			new_url=$(echo "$old_url" | sed "s/\/.*@/\/\/$user_name\@/") # Replaces the first text between '/' and '@' by '/${user_name}@'

		else # Does not have a user configured
			new_url=$(echo "$old_url" | sed "s/\/\//\/\/$user_name@/") # Replaces the first '//' by '//${user_name}'
			git remote set-url "$remote_name" "$new_url"
		fi

		# Removes the 'www.' prefix. Otherwise, Git will ask you the username
		new_url=$(echo "$new_url" | sed 's/@www\./@/')

		# Asks permission
		if [[ $(dialog_ask_boolean "Want to set the user '$user_name' to this remote '$remote_name'?", 'y') == 'n' ]]; then
			echo "Skipping remote '$remote_name'"
			continue
		fi

		# Sets the new URL
		echo "New url to remote '$remote_name': $new_url"
		git remote set-url "$remote_name" "$new_url"
	done
}

# User name
user_name=$(git config --get user.name)

if [[ $(dialog_ask_boolean "Want to use this user '$user_name'?" 'y') == 'n' ]]; then
	user_name=$(dialog_ask_input "New user name")
fi

# New default user name
set_user_of_remotes "$user_name" $(git_get_remotes_name)
