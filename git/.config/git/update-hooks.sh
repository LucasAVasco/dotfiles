#!/bin/bash
#
# Build the Git hooks.
#
# The user hooks must be at '~/.config/git/hooks/src/'. They will be built at '~/.config/git/hooks/built/'

src_hooks_dir=~/.config/git/hooks/src
bult_hooks_dir=~/.config/git/hooks/built

# Execute all commands relative to the current directory
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

# Cleanup
test -d "$bult_hooks_dir" && rm -r "$bult_hooks_dir"
mkdir "$bult_hooks_dir"

# Enables 'git-lfs'. Only need to be done once
touch ~/.gitconfig # `git-lfs` will try to install the configurations in this file
git lfs install --force

# Merge `git-lfs` hooks with my hooks
#
# $1: The name of the hook (relative to the './hooks/src/' folder)
merge_hook() {
	local hook="$1"

	local my_hook="$src_hooks_dir/$hook"
	local dest_hook="$bult_hooks_dir/$hook"

	# Folders are not merged
	if [[ -d "$my_hook" ]]; then
		cp -r "$my_hook" "$dest_hook"

	# Files that does not need to be merged
	elif [[ -f "$my_hook" && ! -f "$dest_hook" ]]; then
		cp "$my_hook" "$dest_hook"

	# Files are merged
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

# Builds all user defined hooks
cd ~/.config/git/hooks/src/
for hook in *; do
	merge_hook "$hook"
done
