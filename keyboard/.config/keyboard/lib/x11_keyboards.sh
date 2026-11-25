#!/bin/bash
#
# Library to access X11 keyboards.

# Outputs the keyboards and their IDs separated by \t. One line per keyboard
x11_keyboards_get() {
	# The first 'grep' filter by slave keyboard. The cut is used to remove the indentation characters | The first 'sed' removes the slave
	# keyboard indicator. The second 'sed' replaces everything between the keyboard name and the ID by a tab. The last 2 call to 'sed' it to
	# remove trailing and leading spaces
	xinput list | grep '\[slave  keyboard' | cut -c 7- | \
		sed 's/ *\[slave  keyboard .*//g' | sed 's/[ \t]*id=/\t/g' | \
		sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}
