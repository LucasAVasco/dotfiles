#!/bin/bash
#
#
# Checkout all submodules to the first temporary branch found. Uses the '../checkout_tmp_branch.sh' script
#
# See the '../checkout_tmp_branch.sh' script for more information

set -e

source ~/.local/custom_scripts/libs/scripts.sh
source ~/.local/custom_scripts/libs/scripts_run.sh
source ~/.local/lib/dotfiles/bash/paths.sh

# Runs all command in the current directory
scripts_cd_to_invoke_dir

# Checkout to the first temporary branch
top_dir=$(paths_get_top_dir "$scripts_current_script_dir")
git submodule foreach "$(scripts_run_get_command "$top_dir/checkout_tmp_branch.sh")"
