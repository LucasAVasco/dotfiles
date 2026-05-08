#!/bin/bash
#
# Fetches updates for each sub module

set -e

source ../lib/enable_cache.sh
source ~/.local/custom_scripts/libs/scripts.sh

# Runs all command in the current directory
scripts_cd_to_invoke_dir

# Enables the git cache. It will be automatically restored when the script ends
enable_git_cache_until_end

# Starts all sub modules (non-recursive)
git submodule update --init

# Pulls updates for each sub module (non-recursive)
git submodule foreach 'git fetch --all'
