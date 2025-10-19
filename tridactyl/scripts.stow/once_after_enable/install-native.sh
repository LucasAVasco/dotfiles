#!/bin/bash
#
# Install native messenger.

set -e

[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && exit 0

version=1.24.4

# Temporary file to download the installation script
tmp_file=$(mktemp /tmp/tridactyl-install-XXXXXX.sh)
trap "rm '$tmp_file'" EXIT

# Based in the instructions at https://github.com/tridactyl/tridactyl
curl -fsSl https://raw.githubusercontent.com/tridactyl/native_messenger/master/installers/install.sh -o "$tmp_file"
sh "$tmp_file" 1.24.4
