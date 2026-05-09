#!/bin/bash
#
# Update JSON schema from YAML or JSON

set -e

source ~/.config/bash/libs/dialog/dialog.sh
source ~/.local/proj-manager/libs/package.sh

package_cd_to_invoke_dir

source_file=$(dialog_ask_input "Enter source file (YAML or JSON)")
dest_file=$(dialog_ask_input "Enter destination file (JSON)")

# Ensure destination file exists
if ! [[ -f "$dest_file" ]]; then
	package_log "Creating $dest_file"
	echo "{}" > "$dest_file"
fi

# Update destination file
package_log "Updating $dest_file"
yq '.. | path | join(".")' "$source_file" | while read key; do
	if [[ -z "$key" ]]; then
		continue
	fi
	key="${key//\./.properties.}"
	key="properties.$key"

	# Only add key if it doesn't exist
	if [[ $(jq ".$key != null" "$dest_file") == 'false' ]]; then
		package_log "Adding '$key' key"
		jq ".$key = {}" "$dest_file" | sponge "$dest_file"
	fi
done
