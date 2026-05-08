#!/bin/bash
#
# Send the clipboard content to another user.

set -e

source ./lib/clipboard.sh

sync_clipboard_send
