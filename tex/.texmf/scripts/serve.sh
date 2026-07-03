#!/bin/bash
#
# Builds the document on file changes.
#
# $@: files to watch

set -e

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)

watch-file "${current_dir}/build.sh" "$@"
