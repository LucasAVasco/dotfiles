#!/bin/bash
#
# Validation functions.

# Check if an environment variable exists. Exits with error if not.
#
# $1: environment variable name.
validate_env_var_exists() {
	if [[ ! -v $1 ]]; then
		echo "'$1' environment variable is not set. Aborting..." 1>&2
		exit 1
	fi
}
