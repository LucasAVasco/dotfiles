#!/bin/bash
#
# Set the labels of a Helm template to use the recommended labels
# (https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/)
#
# Use the Helm helper if one is provided.
#
# You must provide the following environment variables:
#
# - 'TEMPLATE_PATH': The path to the template to update.
# - 'HELM_HELPER': The Helm helper to use. If empty, no helper will be used.
# - 'HELM_NAME_SUFFIX': The suffix to add to the name.
# - 'HELM_COMPONENT': The component to use.
# - 'HELM_PART_OF': The part of to use.

source ~/.local/lib/dotfiles/bash/dialog/dialog.sh
source ~/.local/lib/dotfiles/bash/strict.sh
source ~/.local/lib/dotfiles/bash/validate.sh
source ~/.local/proj-manager/extend-proj/helm/from-docker-compose/lib/labels.sh
source ~/.local/proj-manager/extend-proj/helm/from-docker-compose/lib/template.sh
source ~/.local/proj-manager/libs/package.sh

package_cd_to_invoke_dir

# Parameters
validate_env_var_exists 'TEMPLATE_PATH'
validate_env_var_exists 'HELM_HELPER'
validate_env_var_exists 'HELM_NAME_SUFFIX'
validate_env_var_exists 'HELM_COMPONENT'
validate_env_var_exists 'HELM_PART_OF'
kind=$(yq '.kind' "$TEMPLATE_PATH")

label_set_component "$HELM_COMPONENT"
label_set_part_of "$HELM_PART_OF"

# Run a 'yq' query on the template and overwrite it in place.
#
# $1: The 'yq' query to run.
yq_query() {
	yq -i "$1" "$TEMPLATE_PATH"
}

# Write the selector to the provided key.
#
# Do not include the component label. You must add it manually.
#
# $1: The key to write the selector to.
write_selector() {
	local key="$1"
	local indent="$2"

	if [[ -n "$HELM_HELPER" ]]; then
		SELECTOR=$(template_format_as_string "{{- include \"$HELM_HELPER.labels\" . | nindent $indent }}") \
		yq_query "
			${key}[0] = env(SELECTOR)
		"
	else
		yq_query "
			$(label_get_name_query "$key") |
			$(label_get_instance_query "$key")
		"
	fi
}

# Write the component and part of labels to the provided key.
#
# $1: The key to write the labels to.
write_component_and_part_of_labels() {
	if [[ -n "$HELM_COMPONENT" ]]; then
		yq_query "$(label_get_component_query "$1")"
	fi

	if [[ -n "$HELM_PART_OF" ]]; then
		yq_query "$(label_get_part_of_query "$1")"
	fi
}

# App name
if [[ -n "$HELM_NAME_SUFFIX" ]]; then
	export NAME=$(template_format_as_string "{{ include \"$HELM_HELPER.fullname\" . }}-$HELM_NAME_SUFFIX")
else
	export NAME=$(template_format_as_string "{{ include \"$HELM_HELPER.fullname\" . }}")
fi
yq_query '.metadata.name = env(NAME)'

# Labels
yq_query '.metadata.labels = {}'

if [[ -n "$HELM_HELPER" ]]; then
	write_selector '.metadata.labels' 4
	write_component_and_part_of_labels '.metadata.labels'
else
	yq_query "$(label_get_chart_query '.metadata.labels')"
	write_selector '.metadata.labels' 4
	yq_query "$(label_get_version_query '.metadata.labels')"
	write_component_and_part_of_labels '.metadata.labels'
	yq_query "$(label_get_managed_by_query '.metadata.labels')"
fi

# Kind specific configuration
case "$kind" in
	Deployment)
		yq_query ".spec.selector.matchLabels = {}"
		write_selector '.spec.selector.matchLabels' 6
		yq_query "$(label_get_component_query '.spec.selector.matchLabels')"

		yq_query ".spec.template.metadata.labels = {}"
		write_selector '.spec.template.metadata.labels' 8
		yq_query "$(label_get_component_query '.spec.template.metadata.labels')"
		;;

	Service)
		write_selector '.spec.selector' 4
		yq_query "$(label_get_component_query '.spec.selector')"
		;;

	*)
		package_log "Skipping kind specific configuration for unsupported kind '$kind'"
		;;
esac

# Remove template indicators from the template. Must be the last operation because it makes the file an invalid YAML
template_remove_indicators "$TEMPLATE_PATH"
