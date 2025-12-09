#!/bin/bash
#
# Security functions.

# Checks if the user can execute external software.
#
# Returns 'y' or 'n'
security_check_can_use_external_software() {
	if [[ "$ALLOW_EXTERNAL_SOFTWARE" == 'y' ]]; then
		echo -n 'y'
	else
		echo -n 'n'
	fi
}
