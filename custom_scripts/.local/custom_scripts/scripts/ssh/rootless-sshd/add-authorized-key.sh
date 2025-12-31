#!/bin/bash
#
# Add a public key to the authorized_keys file of my rootless sshd server.

set -e

cd "$WORKING_DIR"

key_path=$(find . -maxdepth 1 -type f -name '*.pub' | fzf)
mkdir -p ~/.ssh/sshd
cat "$key_path" >> ~/.ssh/sshd/authorized_keys
