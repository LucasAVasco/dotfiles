#!/bin/bash
#
# Build the Rust Zsh prompt as a statically linked binary.
#
# Dependencies:
# * Bash
# * Rust toolchain (cargo, rustup)

set -e

current_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
target="x86_64-unknown-linux-musl"
target_dir="${CARGO_TARGET_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh-prompt-target}"

echo "Building the prompt..."

cd "$current_dir"

if command -v rustup >/dev/null 2>&1; then
    if ! rustup target list --installed | grep -qx "$target"; then
        rustup target add "$target"
    fi
fi

CARGO_TARGET_DIR="$target_dir" RUSTFLAGS="-C target-feature=+crt-static" cargo build --release --target "$target"

mkdir -p "$current_dir/build"
cp "$target_dir/$target/release/zsh-prompt" "$current_dir/build/zsh-prompt"
