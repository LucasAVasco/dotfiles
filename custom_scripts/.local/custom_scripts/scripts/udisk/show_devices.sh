#!/bin/bash
#
# Shows the devices status with udisks and lsblk, so the user can see what devices can be mounted, unmounted, etc.
#
# Dependencies:
# * udisks2
# * lsblk

set -e

source "$REPO_DIR/libs/markdown.sh"

show() {
	echo -e '## Udisks status\n'

	echo '```'
	udisksctl status
	echo '```'

	echo -e '\n## Lsblk output\n'

	echo '```'
	lsblk
	echo '```'
}

show | markdown_format
