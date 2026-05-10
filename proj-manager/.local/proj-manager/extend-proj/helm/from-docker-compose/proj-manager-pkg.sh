#!/bin/bash
#
# Convert Docker Compose files to Helm templates

set -e

source ~/.local/lib/dotfiles/bash/dialog/dialog.sh
source ~/.local/proj-manager/libs/package.sh

package_cd_to_invoke_dir

helm_dir=$(dialog_ask_input 'Output Helm directory path')
if [[ -z "$helm_dir" ]]; then
	echo 'Output directory not provided. Aborting...'
	exit 1
fi

# Write the Helm templates to this directory before copying them to the Helm directory
tmp_helm_dir=$(mktemp -d)
trap "trash $tmp_helm_dir" EXIT

package_log "Selecting Docker Compose files..."
compose_files=$(fd 'compose.yaml' | fzf --preview 'pretty-preview {}' --multi)

package_log 'Converting Docker Compose files to Helm templates...'
# cSpell:words kompose
kompose convert --with-kompose-annotation=false --controller deployment -c -o "$tmp_helm_dir" \
	$(echo -n "$compose_files" | foreach-line echo -f /_)

package_log 'Copying generated templates to helm directory...'
mv -i "$tmp_helm_dir"/templates/* "$helm_dir"/templates/
