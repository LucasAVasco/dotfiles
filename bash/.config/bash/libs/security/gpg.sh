#!/bin/bash
#
# Functions to manage GPG keys.

# Check if a GPG key exists.
#
# $1: Key name.
#
# Return 'y' if the key exists, 'n' otherwise.
security_gpg_has_key() {
	gpg --list-secret-keys | grep -q "$1" > /dev/null 2>&1 && \
		echo y || echo n
}

# Generate a GPG key with the default settings.
#
# $1: Key name.
security_gpg_generate_key() {
	gpg --quick-generate-key "$1" default default 0
}

# Generate a GPG key with the default settings if the key does not exist.
#
# $1: Key name.
security_gpg_ensure_key_exists() {
	local Jey_name="$1"
	if [[ $(security_gpg_has_key "$1") == n ]]; then
		security_gpg_generate_key "$1"
	fi
}

# Delete a GPG key.
#
# $1: Key name.
security_gpg_delete_key() {
	gpg --delete-secret-and-public-key "$1"
}
