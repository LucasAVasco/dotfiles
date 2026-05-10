#!/bin/bash
#
# Deletes all pods based on their status

source ~/.local/lib/dotfiles/bash/dialog/dialog.sh

status_filter=$(dialog_ask_selection "Select the status of the pods to delete" 'Failed (ended with error)' 'Succeeded (completed)')
status_filter=${status_filter%% *} # Remove content after spaces

# Ask confirmation
if [[ $(dialog_ask_boolean "Delete $status_filter pods?" n) == n ]]; then
	echo 'Aborted' >&2
	exit
fi

# Delete pods
kubectl get pods --all-namespaces \
	--field-selector=status.phase="$status_filter" \
	-o json | jq -r '.items[] | "\(.metadata.namespace) \(.metadata.name)"' \
	| while read ns pod; do
		kubectl delete pod --namespace "$ns" "$pod"
	done
