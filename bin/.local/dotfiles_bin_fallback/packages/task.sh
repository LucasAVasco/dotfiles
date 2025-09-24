#/bin/bash
#
# Task (https://taskfile.dev/) package.

set -e

source ~/.config/bash/libs/install/go.sh

version='latest'
completion_file="$HOME/.local/share/zsh_completions/_task"

case "$1" in
	i | u)
		install_go_install_package github.com/go-task/task/v3/cmd/task@latest
		task --completion zsh  > "$completion_file"
		;;

	r)
		install_go_remove_package task
		test -f "$completion_file" && rm "$completion_file" || echo "No completions file found"
		;;
esac
