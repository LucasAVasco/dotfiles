#!/bin/bash
#
# Module to manage binaries compiled with Rust.

# Install a package from the Cargo registry.
#
# $1: package name.
# $2..n: options passed to `cargo install`.
install_rust_install_package() {
	cargo install "$@"
}

# Remove a package installed with the Cargo registry.
#
# $1: package name.
install_rust_remove_package() {
	cargo uninstall "$1"
}
