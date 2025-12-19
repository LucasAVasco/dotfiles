#!/bin/bash
#
# Exports the ODS sheets from LibreOffice to CSV files, and formats them to be compatible with 'csvsimple'.
#
# $@: export the sheets from these directories. The CSV files will be created in the same directory.

set -e

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)

# Exports the sheets to CSV
for dir in "$@"; do
	# Filter options at https://wiki.openoffice.org/wiki/Documentation/DevGuide/Spreadsheets/Filter_Options
	libreoffice --convert-to csv:"Text - txt - csv (StarCalc)":"44,34,0,1," --outdir "$dir" "$dir"*.ods
done

# Formats the CSV files to be compatible with 'csvsimple'
"$current_dir/format_csv_to_csvsimple.py" "$@"*.csv
