#!/bin/bash
#
# Clear unreachable git objects

source ~/.local/custom_scripts/libs/scripts.sh
source ~/.config/bash/libs/dialog/dialog.sh

scripts_cd_to_invoke_dir

# Ask for confirmation
if [[ $(dialog_ask_boolean 'Clear unreachable git files?' n) == n ]]; then
	echo "Aborted" >&2
	exit 1
fi

# Clear objects
git reflog expire --expire=now --all # Expire all references
git gc --prune=now --aggressive # Remove unreachable objects
