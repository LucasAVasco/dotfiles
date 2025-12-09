#!/bin/bash
#
# Send the clipboard content to another user.

set -e

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
source "$current_dir/lib/clipboard.sh"

sync_clipboard_send
