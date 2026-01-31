#!/bin/bash

source ~/.local/proj-manager/libs/package.sh
source ~/.local/proj-manager/libs/package_fs.sh

package_handle_cli "$@" << EOF
	Configure Prettier to not add semicolons
EOF

package_cd_to_invoke_dir

if [[ ! -f ./.prettierrc ]]; then
	package_log "Creating .prettierrc"
	echo '{}' >> ./.prettierrc
fi

package_log "Configuring Prettier to not add semicolons"
jq '.semi = false' ./.prettierrc | sponge ./.prettierrc
