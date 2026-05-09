#!/bin/bash
#
# Debug a Kubernetes cluster

set -e

source ~/.config/bash/libs/dialog/dialog.sh
source ~/.local/lib/dotfiles/bash/markdown.sh

# Run a command in the current machine. Print the command before running it
#
# $@: The command to run
run_command() {
	printf '# %s' "$*" | markdown_format
	echo ""

	command "$@"
}

# Run a command in a remote machine. Print the command before running it
#
# $@: The command to run
# $ssh_conn: The SSH connection name to use
run_command_with_ssh() {
	run_command ssh "$ssh_conn" "$@"
}

# Nodes information
run_command kubectl get nodes
run_command kubectl top nodes

# Events
run_command kubectl get events --sort-by=.lastTimestamp

# SSH connection to use with the next commands
ssh_conn=$(dialog_ask_input "SSH connection to the node")
if [[ -z "$ssh_conn" ]]; then
	echo 'No SSH connection selected, exiting...' >&2
	exit
fi

# System status
if [[ $(kubectl version -o json | jq -r '.serverVersion.gitVersion' | grep k3s) =~ .*k3s.* ]]; then
	run_command_with_ssh sudo systemctl status k3s
fi

run_command_with_ssh free -m
run_command_with_ssh df -h

# Logs
run_command_with_ssh sudo journalctl -u kubelet
run_command_with_ssh 'sudo dmesg | grep -i oom | true'
