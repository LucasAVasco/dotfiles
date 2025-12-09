#!/bin/bash
#
# Creates backup commits in all sub modules of the current repository
#
# See the 'backup.sh' script for more information


set -e


top_dir=$(realpath -m -- "$0/../../")
git submodule foreach "${top_dir}/backup.sh"
