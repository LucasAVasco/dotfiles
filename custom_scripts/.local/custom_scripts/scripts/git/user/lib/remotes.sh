#!/bin/bash
#
# Functions to manage remotes.

# Return the names of all remotes.
#
# Return: A string with the names of the remotes separated by new lines.
git_get_remotes_name() {
	git remote
}

# Return the URL of a remote.
#
# $1: The name of the remote.
#
# Return: A string with the URL.
git_get_remote_url() {
	git remote get-url "$1"
}
