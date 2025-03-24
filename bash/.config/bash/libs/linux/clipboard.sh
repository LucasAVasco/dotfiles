#!/bin/bash
#
# Library to manage the clipboard.

linux_clipboard_copy_script=~/.config/clipboard/copy.sh
linux_clipboard_paste_script=~/.config/clipboard/paste.sh
linux_clipboard_clear_script=~/.config/clipboard/clear.sh

linux_clipboard_copy () {
	"$linux_clipboard_copy_script" "$@"
}

linux_clipboard_paste () {
	"$linux_clipboard_paste_script" "$@"
}

linux_clipboard_clear () {
	"$linux_clipboard_clear_script" "$@"
}
