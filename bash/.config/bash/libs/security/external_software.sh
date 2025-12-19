#!/bin/bash
#
# Library to check if external software is allowed.

security_external_software_allowed=n

if [[ "$ALLOW_EXTERNAL_SOFTWARE" == 'y' ]]; then
	security_external_software_allowed=y
fi
