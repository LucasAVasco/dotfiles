# Opens the default file manager in the current directory. After closing it, it changes to the last directory visited by the file manager.
#
# Based in the official documentation at https://yazi-rs.github.io/docs/quick-start
#
# $@: Arguments to pass to file manager.
default_term_file_manager_cd() {
	# New temporary file with the contents of the current directory
	local cwd_file=$(mktemp -t "$USER"-yazi_cwd.XXXXXXXXX)

	yazi --cwd-file="$cwd_file" "$@"

	# Changes the current directory to the last one visited by Yazi
	new_cwd=$(/bin/cat -- "$cwd_file")
	if [[ -n "$new_cwd" ]]; then
		cd -- "$new_cwd"
	fi

	# Removes the temporary file
	rm -f -- "$cwd_file"
}
