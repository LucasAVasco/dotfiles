#!/bin/bash
#
# 'pass' setup. Only initializes once.

set -e

# Does nothing if '~/.password-store' already exists
if [[ -d ~/.password-store ]]; then
	exit 0
fi

# Libraries
source ~/.config/bash/libs/security/gpg.sh
source ~/.config/bash/libs/dialog/dialog.sh

# Confirms with the user
create=$(dialog_ask_boolean "The directory '~/.password-store' doesn't exist. Do you want to create it?")
if [[ "$create" != 'y' ]]; then
	echo "Aborting" >&2
	exit 1
fi

# Creates the key to encrypt the password database
security_gpg_ensure_key_exists 'pass'

# Initializes pass
pass init pass
pass git init
