#!/bin/bash
#
# Functions manage Helm templates labels.

source ~/.local/proj-manager/extend-proj/helm/from-docker-compose/lib/template.sh

export LABEL_KUBE_CHART=$(template_format_as_string '{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}')
export LABEL_NAME=$(template_format_as_string '{{ .Chart.Name }}')
export LABEL_INSTANCE=$(template_format_as_string '{{ .Release.Name }}')
export LABEL_VERSION=$(template_format_as_string '{{ .Chart.AppVersion | quote }}')
# export LABEL_COMPONENT=# Set by 'label_set_component' function
# export LABEL_PART_OF=# Set by 'label_set_part_of' function
export LABEL_MANAGED_BY=$(template_format_as_string '{{ .Release.Service }}')

# Set the component label.
#
# $1: The component label.
label_set_component() {
	export LABEL_COMPONENT="$1"
}

# Set the part of label.
#
# $1: The part of label.
label_set_part_of() {
	export LABEL_PART_OF="$1"
}

# Get a query to set the chart label.
#
# $1: The key to write the label to.
label_get_chart_query() {
	local key="$1"
	echo -n "${key}.[\"app.kubernetes.io/chart\"] = env(LABEL_KUBE_CHART)"
}

# Get a query to set the name label.
#
# $1: The key to write the label to.
label_get_name_query() {
	local key="$1"
	echo -n "${key}.[\"app.kubernetes.io/name\"] = env(LABEL_NAME)"
}

# Get a query to set the instance label.
#
# $1: The key to write the label to.
label_get_instance_query() {
	local key="$1"
	echo -n "${key}.[\"app.kubernetes.io/instance\"] = env(LABEL_INSTANCE)"
}

# Get a query to set the version label.
#
# $1: The key to write the label to.
label_get_version_query() {
	local key="$1"
	echo -n "${key}.[\"app.kubernetes.io/version\"] = env(LABEL_VERSION)"
}

# Get a query to set the component label.
#
# $1: The key to write the label to.
label_get_component_query() {
	local key="$1"
	echo -n "${key}.[\"app.kubernetes.io/component\"] = env(LABEL_COMPONENT)"
}

# Get a query to set the part of label.
#
# $1: The key to write the label to.
label_get_part_of_query() {
	local key="$1"
	echo -n "${key}.[\"app.kubernetes.io/part-of\"] = env(LABEL_PART_OF)"
}

# Get a query to set the managed by label.
#
# $1: The key to write the label to.
label_get_managed_by_query() {
	local key="$1"
	echo -n "${key}.[\"app.kubernetes.io/managed-by\"] = env(LABEL_MANAGED_BY)"
}
