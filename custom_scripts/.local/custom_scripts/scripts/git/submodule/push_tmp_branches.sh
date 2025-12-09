#!/bin/bash
#
#
# Push all temporary branches of all sub modules to its temporary remote. Uses the '../push_tmp_branches.sh' script
# to push each sub module


set -e


# Sources other scripts
top_dir=$(realpath -m -- "$0/../../")
source "${top_dir}/lib/enable_cache.sh"


# Enables the git cache. It will be automatically restored when the script ends
enable_git_cache_until_end


# Pushes all temporary branches of the submodules
git submodule foreach "${top_dir}/push_tmp_branches.sh"
