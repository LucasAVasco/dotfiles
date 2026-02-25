#!/bin/bash

# Check if a remote exists
#
# $1: remote
#
# Return 'y' if the remote exists, 'n' if it doesn't
git_remote_has() {
	git remote show "$1" >/dev/null 2>&1 && echo 'y' || echo 'n'
}
