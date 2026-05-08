#!/bin/bash
#
# Push all temporary branches of all sub modules to its temporary remote. Uses the '../push_tmp_branches.sh' script
# to push each sub module

set -e

source ../lib/enable_cache.sh
source ~/.local/custom_scripts/libs/scripts.sh
source ~/.local/custom_scripts/libs/scripts_run.sh
source ~/.local/lib/dotfiles/bash/paths.sh

# Runs all command in the current directory
scripts_cd_to_invoke_dir

# Enables the git cache. It will be automatically restored when the script ends
enable_git_cache_until_end

# Pushes all temporary branches of the submodules
top_dir=$(paths_get_top_dir "$scripts_current_script_dir")
git submodule foreach "$(scripts_run_get_command "$top_dir/push_tmp_branches.sh")"
