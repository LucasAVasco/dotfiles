#!/bin/bash
#
# Run the sshd server in rootless mode.

set -e

source ~/.config/bash/libs/dialog/dialog.sh

# Folders
mkdir -p ~/.ssh/sshd/run
chmod -R u=rwX,g=,o= ~/.ssh

# Keys
if [[ ! -f ~/.ssh/sshd/host_ed25519_key ]]; then
	ssh-keygen -t ed25519 -f ~/.ssh/sshd/host_ed25519_key -N ''
fi

if [[ ! -f ~/.ssh/sshd/host_rsa_key ]]; then
	ssh-keygen -t rsa -b 4096 -f ~/.ssh/sshd/host_rsa_key -N ''
fi

# Listen address
expose_to_internet=$(dialog_ask_boolean 'Do you want to expose the server to the internet?' 'n')
if [[ "$expose_to_internet" == 'y' ]]; then
	export LISTEN_ADDRESS='0.0.0.0'
else
	export LISTEN_ADDRESS='127.0.0.1'
fi

# Configuration file
cat ./lib/sshd.conf | envsubst > ~/.ssh/sshd/sshd.conf

# Starts the server
/usr/sbin/sshd -D -f ~/.ssh/sshd/sshd.conf
