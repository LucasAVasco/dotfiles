#!/bin/bash

# Install a binary from a NPM package
#
# $1: NPM package.
install_node_install_package() {
	npm install -g "$1"
}

# Remove a binary installed with a NPM package.
#
# $1: NPM package.
install_node_remove_package() {
	npm uninstall -g "$1"
}
