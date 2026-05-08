#!/bin/bash
#
# Add a public key to the authorized_keys file of my rootless sshd server.

set -e

source ~/.local/custom_scripts/libs/scripts.sh

# Runs all command in the current directory
scripts_cd_to_invoke_dir

# Find the key
key_path=$(find . -maxdepth 1 -type f -name '*.pub' | fzf)
mkdir -p ~/.ssh/sshd

# Add the key
cat "$key_path" >> ~/.ssh/sshd/authorized_keys
