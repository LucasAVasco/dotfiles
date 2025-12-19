#!/bin/bash
#
# Create the KeePassXC password database.

set -e

# Checks if the password file already exists
if [[ -f "$HOME/.secrets/keepassxc/secret-service.kdbx" ]]; then
	notify-send 'KeePassXC-service' 'password file already exists. Aborting.'
	exit 1
fi

notify-send 'KeePassXC-service' 'password file not found. You need to create it and save to ~/Passwords.kdbx'

# Temporary configuration files (avoid mess with the real ones)
config=$(mktemp)
localconfig=$(mktemp)
trap "rm $config $localconfig" EXIT

# Starts KeePassXC. The user must create the password file manually
keepassxc --config "$config" --localconfig "$localconfig"

# Checks if the password was not created by another instance of KeePassXC
if [[ -f "$HOME/.secrets/keepassxc/secret-service.kdbx" ]]; then
	notify-send 'KeePassXC-service' 'password file already exists. Aborting.'
	exit 1
fi

# Moves the password file to the right place
mkdir -p ~/.secrets/keepassxc
mv -i ~/Passwords.kdbx ~/.secrets/keepassxc/secret-service.kdbx
