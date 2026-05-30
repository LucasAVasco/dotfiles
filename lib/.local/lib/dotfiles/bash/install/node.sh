#!/bin/bash
#
# Module to install Node packages

# Install a binary from a NPM package
#
# $@: NPM packages and `pnpm install` options
install_node_install_package() {
	pnpm install -g "$@"
	mise reshim
}

# Remove a binary installed with a NPM package.
#
# $@: NPM packages and `pnpm uninstall` options
install_node_remove_package() {
	pnpm uninstall -g "$@"
	mise reshim
}
