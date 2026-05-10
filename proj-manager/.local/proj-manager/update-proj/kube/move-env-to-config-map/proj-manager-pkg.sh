#!/bin/bash
#
# Move environment variables from a container definition to a config map in the same file (append to the end of the file)

set -e

source ~/.local/lib/dotfiles/bash/dialog/dialog.sh
source ~/.local/proj-manager/libs/package.sh

package_cd_to_invoke_dir

file_path=$(dialog_ask_selection "Select file to extract env from" $(fd '\.yaml'))
index=$(dialog_ask_input "Index of the container to extract env from")

# Extract env
envs=$(yq ".spec.template.spec.containers.[$index].env" "$file_path" | \
	yq eval '.[] as $item | "\($item.name): \($item.value)"')

# Create config map without data
cat <<EOF >> "$file_path"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: replace-me
data:
EOF

# Add environment variables as data
printf "%s" "$envs" | sed 's/^/  /' >> "$file_path"
