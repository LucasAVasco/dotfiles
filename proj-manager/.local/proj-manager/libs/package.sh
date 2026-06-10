#!/bin/bash
#
# Library with the basic functions that a package provider needs

source ~/.local/lib/dotfiles/bash/help.sh
source ~/.local/lib/dotfiles/bash/log.sh

package_manager_dir="$PM_MANAGER_DIR"
package_provider_dir="$PM_PROVIDER_DIR"
package_invoke_dir="$PM_INVOKE_DIR"

# Change the directory to the one that the user was when the CLI was called
package_cd_to_invoke_dir() {
	cd "$PM_INVOKE_DIR"
}

# Log an info message.
#
# $1: message.
#
# stdout: formatted message.
package_log() {
	log_info "$@"
}

# Log an error message and exit with an error code.
#
# $1: message.
# $2: error code. Optional. Default: 1
#
# stdout: formatted message.
package_error() {
	log_error "$@"
}
