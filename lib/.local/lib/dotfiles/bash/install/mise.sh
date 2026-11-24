#!/bin/bash
#
# Module to manage mise packages.

# Install a mise package.
#
# $1: package name.
# $2..n: options passed to `mise use -g`.
install_mise_install_package() {
	mise use -g "$@"
	mise reshim
}

# Remove a mise package installed.
#
# $1: package name.
# $2..n: options passed to `mise unuse -g`.
install_mise_remove_package() {
	mise unuse -g "$@"
	mise reshim
}
