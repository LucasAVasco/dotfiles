#!/bin/bash


set -e


# Sources other scripts
top_dir=$(realpath -m -- "$0/../../")
source "${top_dir}/lib/enable_cache.sh"


# Enables the git cache. It will be automatically restored when the script ends
enable_git_cache_until_end


# Starts all sub modules (non-recursive)
git submodule update --init


# Pulls updates for each sub module (non-recursive)
git submodule foreach 'git fetch --all'
