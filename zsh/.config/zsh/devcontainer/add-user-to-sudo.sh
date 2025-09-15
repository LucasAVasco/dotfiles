#!/bin/bash
#
# Add a user to the `sudo` group.
#
# Usage: `./add-user-to-sudo.sh <user>`

set -e

user="$1"

# Add user to `sudo` group
[[ -f /usr/bin/usermod ]] && usermod -a -G sudo "$user"
[[ -f /usr/bin/addgroup ]] && addgroup "$user" sudo

# Inline definition to add `sudo` access to devcontainer user
if [[ $(grep 'DEVCONTAINER USER' /etc/sudoers) ]]; then
	exit 0 # User already exists
fi

cat > /etc/sudoers << EOF

# DEVCONTAINER USER
$user ALL=(ALL:ALL) ALL
EOF
