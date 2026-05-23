#!/bin/bash
#
# Library to check if external software is allowed.

security_external_software_allowed=n
if [[ "${ALLOW_EXTERNAL_SOFTWARE:-}" == 'y' ]]; then
	security_external_software_allowed=y
fi

# Exit if the user can not install external software
#
# $1: Error message. Optional. Default: ''
# $2: Error code. Optional. Default: 0
security_external_software_exit_if_not_allowed() {
	if [[ $security_external_software_allowed == n ]]; then
		printf '%s\n' "${1:-}"
		exit "${2:-0}"
	fi
}
