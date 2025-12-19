#!/bin/bash
#
# Run KeePassXC in the background as a freedesktop.org secrets service (see https://specifications.freedesktop.org/secret-service/latest/).

set -e

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

# KeePassXC configuration with the defaults to run as a freedesktop.org secrets service
if [[ ! -f ~/.config/keepassxc/keepassxc.ini ]]; then
	cp -i ./keepassxc-conf.ini ~/.config/keepassxc/keepassxc.ini
fi

# Default KeePassXC password database
if [[ ! -f "$HOME/.secrets/keepassxc/secret-service.kdbx" ]]; then
	./keepasscx-service-password-creator.sh
fi

# Launches KeePassXC
exec keepassxc --minimized ~/.secrets/keepassxc/secret-service.kdbx
