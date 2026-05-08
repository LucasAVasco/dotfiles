#!/bin/bash
#
# 'wasm-pack' (https://github.com/wasm-bindgen/wasm-pack) package.

set -e

source ~/.config/bash/libs/install/rust.sh

case "$1" in
	i | u)
		install_rust_install_package wasm-pack
		;;

	r)
		install_rust_remove_package wasm-pack
		;;
esac
