#!/bin/bash
#
# Create shim binaries that execute 'nix' commands with 'nix-user-chroot'

set -e

# Does not run this scripts if the user can not install external software
[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && return

# All operations are relative to the current directory
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

# Nix commands to be masked (run with `nix-user-chroot`)
declare -a nix_commands=(
	nix
	nix-build
	nix-channel
	nix-collect-garbage
	nix-copy-closure
	nix-daemon
	nix-env
	nix-hash
	nix-instantiate
	nix-prefetch-url
	nix-shell
	nix-store
)

# Creates the bin directory
test -d ./bin && rm -r ./bin
mkdir ./bin
for command in "${nix_commands[@]}"; do
	cat <<-EOF > ./bin/"$command"
		#!/bin/bash

		exec nix-user-chroot ~/.nix '$command' "\$@"
EOF

	chmod +x ./bin/"$command"
done
