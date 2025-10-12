#!/bin/bash
#
# My custom diff-dir package.

set -e

source ../lib/bin.sh

case "$1" in
	i | u)
		~/.local/dev/diff-dir/build.sh
		bin_copy_files ~/.local/dev/diff-dir/build/diff-dir
		;;
	r)
		bin_delete_files diff-dir
		;;
esac
