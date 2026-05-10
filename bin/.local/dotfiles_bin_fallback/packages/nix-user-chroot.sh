#!/bin/bash
#
# nix-user-chroot (https://github.com/nix-community/nix-user-chroot) package.

set -e

source ~/.local/lib/dotfiles/bash/install/rust.sh

case "$1" in
	i | u)
		install_rust_install_package nix-user-chroot

		# From the official documentation at https://github.com/nix-community/nix-user-chroot (I just added the '-p' flag to `mkdir` and set
		# the permission flags to 0700):
		mkdir -p -m 0700 ~/.nix
		nix-user-chroot ~/.nix bash -c "curl -L https://nixos.org/nix/install | bash"
		;;

	r)
		install_rust_remove_package nix-user-chroot
		;;
esac
