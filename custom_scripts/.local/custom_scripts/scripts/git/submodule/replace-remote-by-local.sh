#!/bin/bash
#
# Replaces the remote of a submodule by a local path.
#
# The user selects the remote and the local repository path (host machine). The script configures the submodule remote to point to this
# local path instead of the remote one. The user can fetch data and pull data from this local repository.

source ~/.config/bash/libs/dialog/dialog.sh
source ~/.config/bash/libs/log.sh
source ~/.local/custom_scripts/libs/scripts.sh

# Returns the name and path of all submodules
#
# Returns: name path
get_submodules_name_and_path() {
	git submodule foreach --quiet 'echo $name $path'
}

# Runs all command in the current directory
scripts_cd_to_invoke_dir

# Changes to the Git root directory
cd "$(git rev-parse --show-toplevel)"

# Selects the submodule to change
submodule=$(get_submodules_name_and_path | fzf --header="Select submodule")
submodule_name=$(echo "$submodule" | cut -d' ' -f1)
submodule_path=$(echo "$submodule" | cut -d' ' -f2)

# Selects the new remote path
new_remote_path=$(file-chooser --only-dirs ~/Repositories/)

accepts=$(dialog_ask_boolean \
	"Do you want to change the remote of the submodule '$submodule_name' from '$submodule_path' to '$new_remote_path'?" n)
if [[ "$accepts" == 'n' ]]; then
	exit 1
fi

# Changes the URL of the submodule
log_info "Changing URL of submodule '$submodule_name' to '$new_remote_path'"
git config set --local "submodule.${submodule_name}.url" "$new_remote_path"

# Changes the remote of the submodule
log_info "Changing remote of submodule '$submodule_name' to '$new_remote_path'"
cd "$submodule_path"
git remote set-url origin "$new_remote_path"
