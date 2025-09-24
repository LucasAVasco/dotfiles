#!/bin/bash
#
# Install vcpkg (https://vcpkg.io/en/)

set -e

source ../lib/bin.sh

install_dir=~/.cache/vcpkg-install/

case "$1" in
	i | u)
		if [[ ! -d "$install_dir" ]]; then
			# Fresh installation
			mkdir -p "$install_dir"
			git clone https://github.com/microsoft/vcpkg.git "$install_dir"
		else
			# Update
			cd "$install_dir"
			git pull
		fi

		cd "$install_dir"
		./bootstrap-vcpkg.sh
		ln -sf "$install_dir/vcpkg" "$DOTFILES_FALLBACK_BIN/vcpkg"
		;;

	r)
		test -d "$install_dir" && trash "$install_dir" || echo "Directory '$install_dir' does not exist."

		if [[ -f "$DOTFILES_FALLBACK_BIN/vcpkg" ]]; then
			rm "$DOTFILES_FALLBACK_BIN/vcpkg"
			echo "Executable '$DOTFILES_FALLBACK_BIN/vcpkg' does not exist."
		fi
		;;
esac
