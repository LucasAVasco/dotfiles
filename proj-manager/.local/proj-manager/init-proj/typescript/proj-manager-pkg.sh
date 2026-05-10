#!/bin/bash
#
# Initialize a sample TypeScript project

set -e

source ~/.local/lib/dotfiles/bash/dialog/dialog.sh
source ~/.local/lib/dotfiles/bash/pkg_manager/node.sh
source ~/.local/proj-manager/libs/package.sh
source ~/.local/proj-manager/libs/package_run.sh

package_cd_to_invoke_dir

manager=$(dialog_ask_selection 'Select a package manager' 'npm' 'pnpm' 'yarn')
if [[ -z "$manager" ]]; then
	echo 'No package manager selected'
	exit 1
fi

package_log 'Initializing a Typescript project...'
pkg_manager_node_init . "$manager"

package_log 'Installing dev dependencies...'
pkg_manager_node_install_packages_as_dev . @types/node typescript npm-run-all

package_log "Generating sample 'tsconfig.json'..."
pkg_manager_node_exec . tsc --init

package_log 'Creating .gitignore...'
echo '/node_modules/' >> .gitignore

package_log "Adding 'package.json' scripts..."
cat package.json \
	| jq '.scripts.clean = "node -e \"fs.rmSync('\''./dist'\'', { recursive: true, force: true })\""'\
	| jq '.scripts["only-build"] = "tsc"'\
	| jq '.scripts["build"] = "run-s clean only-build"'\
	| sponge package.json

package_log "Creating 'src/index.ts'..."
mkdir -p src
cat << EOF > src/index.ts
console.log('Hello, World!')
EOF

# Run the extension scripts
package_run_extend_provider json/2-spaces
package_run_extend_provider prettier/no-semi-colons
package_run_extend_provider typescript/4-spaces
