#!/bin/bash
#
# Receive the clipboard content from another user.

set -e

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
source "$current_dir/lib/clipboard.sh"

sync_clipboard_receive
