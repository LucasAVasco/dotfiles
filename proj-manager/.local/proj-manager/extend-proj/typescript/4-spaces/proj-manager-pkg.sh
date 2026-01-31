#!/bin/bash

source ~/.local/proj-manager/libs/package.sh
source ~/.local/proj-manager/libs/package_fs.sh

package_handle_cli "$@" << EOF
	Extend a Typescript project to use 4 spaces for JavaScript and Typescript indentation
EOF

package_log 'Configuring JavaScript and TypeScript to use 4 spaces for indentation'
package_fs_append_file ./.editorconfig .
