#!/bin/bash
#
# Library to sync the clipboard between users.

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
top_dir=$(dirname "$current_dir")

source "$top_dir/../lib/sync_folder.sh"

# Fifo used to sync the clipboard
clipboard_fifo="$SYNC_FOLDER/clipboard.fifo"

# Send the clipboard to the sync folder.
#
# This is a blocking operation. Waits for some user to receive the clipboard.
sync_clipboard_send() {
	if [[ -e "$clipboard_fifo" ]]; then
		rm "$clipboard_fifo"
	fi

	# Removes the fifo on exit
	trap "rm '$clipboard_fifo'" EXIT

	# Creates the fifo
	mkfifo "$clipboard_fifo"
	chmod g=r "$clipboard_fifo"

	# Sends the clipboard
	local content=$(clip-paste)
	printf "%s" "$content" > "$clipboard_fifo" &

	# Notifies the user
	notify-send -t 30000 -A Abort=abort -a "Clipboard sync" \
		"Clipboard sent" \
		"The clipboard content has been sent. The operation will be aborted after a few seconds or the notification dismisses."
}

# Receive the clipboard from the sync folder.
sync_clipboard_receive() {
	local content=$(cat "$clipboard_fifo")

	# Removes the clipboard content after exit
	trap clip-clean EXIT

	# Copies to the clipboard
	printf "%s" "$content" | clip-copy -c 30

	# Notifies the user
	notify-send -t 30000 -A Clear=clear -a "Clipboard sync"  \
		"Clipboard received" \
		"The clipboard content has been received. It will be cleared after a few seconds or the notification dismisses."
}
