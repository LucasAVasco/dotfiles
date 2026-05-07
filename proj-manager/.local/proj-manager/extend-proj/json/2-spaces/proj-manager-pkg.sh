#!/bin/bash
#
# Extend a project to use 2 spaces for JSON and JSONC

source ~/.local/proj-manager/libs/package.sh
source ~/.local/proj-manager/libs/package_fs.sh

package_log 'Configuring JSON and JSONC to use 2 spaces for indentation'
package_fs_append_file ./.editorconfig .
