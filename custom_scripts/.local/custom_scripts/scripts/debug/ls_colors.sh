#!/bin/bash
#
# Debug the LS_COLORS environment variable. Show each file pattern and the associated color

source ~/.local/lib/dotfiles/bash/strict.sh

# Uses to limit the number of columns
current_column=0
max_column_per_line=7

while read entry; do
	file_pattern="${entry%%=*}"
	color="${entry##*=}"

	echo -en "\x1b[${color}m$file_pattern\x1b[0m"

	if [[ $current_column -eq $max_column_per_line ]]; then
		# Next line
		echo
		current_column=0
	else
		# Next column
		echo -en '\t'
		current_column=$((current_column + 1))
	fi
done < <(echo "$LS_COLORS" | tr ':' '\n') # Each line is a LS_COLORS entry

echo -e '\n\n'
