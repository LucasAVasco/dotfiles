#!/bin/bash
#
# Module to install Node packages

# Install a binary from a NPM package
#
# $1: NPM package.
install_node_install_package() {
	pnpm install -g "$1"
}

# Remove a binary installed with a NPM package.
#
# $1: NPM package.
install_node_remove_package() {
	pnpm uninstall -g "$1"
}
