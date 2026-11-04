#!/bin/bash
#
# Update a python project (managed with mise) to the latest python version

source ~/.local/proj-manager/libs/package_run.sh

package_cd_to_invoke_dir
python_version="$(mise latest python)"
mise use python@"$python_version"
