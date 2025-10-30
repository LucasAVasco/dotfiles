#!/bin/bash

# Folder to hold the hooks
test -d ~/.config/git/template/hooks && rm -r ~/.config/git/template/hooks
mkdir ~/.config/git/template/hooks

# Enable 'git-lfs'. Only need to be done once
touch ~/.gitconfig # `git-lfs` will try to install the configurations in this file
git lfs install --force

# Merge `git-lfs` hooks with my hooks
merge_hook() {
	local hook="$1"

	local my_hook=~/.config/git/hooks/"$hook"
	local dest_hook=~/.config/git/template/hooks/"$hook"

	# Folders are not merged
	if [[ -d "$my_hook" ]]; then
		cp -r "$my_hook" "$dest_hook"

	# Files are merged
	elif [[ -f "$my_hook" && ! -f "$dest_hook" ]]; then
		cp "$my_hook" "$dest_hook"

	# Files that does not need to be merged
	elif [[ -f "$my_hook" && -f "$dest_hook" ]]; then
		local my_hook_content="$(cat "$my_hook")"
		local dest_hook_content="$(cat "$dest_hook")"
		printf '%s\n\n# End of my Hook\n\n%s' "$my_hook_content" "$dest_hook_content" > "$dest_hook"

	# Undefined behavior
	else
		echo "No hook found for $hook" >&2
		exit 1
	fi

}

cd ~/.config/git/hooks/
for hook in *; do
	merge_hook "$hook"
done
