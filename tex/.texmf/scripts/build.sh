#!/bin/bash
#
# Builds the document. If the 'attach' directory exists, it will be appended to the output file.
#
# Environment variables:
#
# - OUTPUT_FILE: the output file path.
# - SHELL_ESCAPE: whether to enable shell escape in the LaTeX document.

set -e

# Activates the Python virtual environment (required by 'pygments' and 'catppuccin')
if [[ -d .venv ]]; then
	source .venv/bin/activate
fi

# Command line arguments for pdflatex
args=()
if [[ "$SHELL_ESCAPE" == y ]]; then
	args+=(-shell-escape)
fi

# Compiles the document
mkdir -p build/latex
pdflatex "${args[@]}" -output-directory ./build/latex ./main.tex

# The output file must be set
if [[ -z "$OUTPUT_FILE" ]]; then
	echo "ERROR: OUTPUT_FILE is not set" >&2
	exit 1
fi

# Check if there are any attachments to append to the output file.
#
# Return 'y' if there are attachments, 'n' otherwise
has_attachments() {
	if [[ ! -d 'attach' ]]; then
		echo n
		return
	fi

	shopt -s nullglob
	pdf_files=(./attach/*.pdf)

	if [[ ${#pdf_files[@]} -gt 0 ]]; then
		echo y
	else
		echo n
	fi
}

# Generates the output file
if [[ $(has_attachments) == y ]]; then
	pdftk build/latex/main.pdf ./attach/*.pdf cat output "$OUTPUT_FILE"
else
	cp ./build/latex/main.pdf "$OUTPUT_FILE"
fi
