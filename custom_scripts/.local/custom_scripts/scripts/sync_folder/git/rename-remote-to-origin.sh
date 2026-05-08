#!/bin/bash
#
# Rename the sync-folder remote to 'origin'

source ~/.local/custom_scripts/libs/scripts.sh

scripts_cd_to_invoke_dir

git remote rename sync-folder origin
