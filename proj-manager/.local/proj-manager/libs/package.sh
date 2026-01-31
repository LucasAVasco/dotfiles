#!/bin/bash
#
# Library with the basic functions that a package provider needs

source ~/.config/bash/libs/help.sh
source ~/.config/bash/libs/log.sh

# Handle the CLI arguments passed to the package (e.g. shows the package description if the runner requires the description).
#
# It will handle the commands that the user provided and ends unless the user provided the 'run' command. You should call this function
# before the main function of the package.
#
# $@: all the CLI arguments
# $stdin: The package description
package_handle_cli() {
	if [[ "$1" == desc ]]; then
		help_msg_remove_indent
		exit
	fi

	if [[ "$1" != run ]]; then
		exit 1
	fi
}

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
