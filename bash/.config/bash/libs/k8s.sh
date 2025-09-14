#!/bin/bash
#
# Utility library related to Kubernetes (k8s and k3s).

# Get the current `kubectl` context.
#
# Return the context name.
k8s_get_current_context() {
	kubectl config current-context
}

# Return all contexts names separated by new lines.
#
# Return the context names separated by new lines.
k8s_get_available_contexts() {
	# ´tail´ removes the first line (header) | cut removes the '*' character (if any) | `awk` selects the context name
	kubectl config get-contexts | tail +2  | cut -d' ' -f 2- | awk '{print$1}'
}

# Set the current Kubernetes context.
#
# $1: Context name.
k8s_use_context() {
	kubectl config use-context "$1"
}
