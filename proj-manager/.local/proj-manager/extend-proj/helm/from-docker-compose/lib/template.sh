#!/bin/bash
#
# Functions to manage Helm templates.

# INFO(LucasAVasco): Because 'yq' can not work with helm templates, the template as treated as strings and indicators are used to mark the
# start and end of the template (`<START_TEMPLATE>` and `<END_TEMPLATE>`). They are removed by the `template_remove_indicators()` function.

# Format a template as a string so it can be used with 'yq'.
#
# $1: The template content.
template_format_as_string() {
	echo -n "<START_TEMPLATE> $1 <END_TEMPLATE>"
}


# Remove the left and right templates indicators. Also remove lines indexes that starts with left quotes indicator
# (e.g. '0: START_TEMPLATE')
#
# After this function is called, the file will no longer be a valid YAML, so it no longer can be used with 'yq'.
#
# $1: The template path
template_remove_indicators() {
	local template_path="$1"

	cat "$template_path" | sed 's/[0-9].*: *<START_TEMPLATE> *//g' | sed 's/<START_TEMPLATE> *//g' | sed 's/ *<END_TEMPLATE>//g' \
		| sponge "$template_path"
}
