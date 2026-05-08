#!/bin/bash
#
# Creates backup commits in all sub modules of the current repository
#
# See the 'backup.sh' script for more information

set -e

source ~/.local/custom_scripts/libs/scripts.sh
source ~/.local/custom_scripts/libs/scripts_run.sh
source ~/.local/lib/dotfiles/bash/paths.sh

# Runs all command in the current directory
scripts_cd_to_invoke_dir

# Creates backup commits in all sub modules
top_dir=$(paths_get_top_dir "$scripts_current_script_dir")
git submodule foreach "$(scripts_run_get_command "$top_dir/backup.sh")"
