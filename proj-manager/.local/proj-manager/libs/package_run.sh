#!/bin/bash
#
# Library to run package providers

source ~/.local/lib/dotfiles/bash/paths.sh
source ~/.local/proj-manager/libs/package.sh

package_run_proj_manager_file_basename="proj-manager-pkg.sh"

# Runs a provider script
#
# $1: The provider folder. If it's a relative path, it will be relative to 'proj-manager' root folder
# $2..n: The arguments to pass to the provider
#
# stdout: The output of the provider script
package_run_provider() {
	local provider_folder="$1"
	if [[ $(paths_is_abs "$provider_folder") == n ]]; then
		provider_folder="$HOME/.local/proj-manager/$provider_folder"
	fi
	provider_folder=$(realpath -m "$provider_folder")

	local script="$provider_folder/$package_run_proj_manager_file_basename"
	package_log "Running provider '$script' with arguments '${@:2}'"
	(
		cd "$provider_folder"
		PM_PROVIDER_DIR="$provider_folder" "$script" run "${@:2}"
	)
}
