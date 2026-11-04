#!/bin/bash
#
# Update mise version of the package.

source ~/.local/proj-manager/libs/package_run.sh

package_cd_to_invoke_dir
mise_version=$(mise -v | cut -f1 -d' ')
mise config set min_version="$mise_version"
