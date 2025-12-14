# Opens the default file manager in the current directory. After closing it, it changes to the last directory visited by the file manager.
#
# Based in the official documentation at https://wiki.vifm.info/index.php/How_to_set_shell_working_directory_after_leaving_Vifm
#
# $@: Arguments to pass to file manager.
default_term_file_manager_cd() {
	local chosen="$(command vifm --choose-dir - "$@")"
	if [[ -z "$chosen" ]]; then
		echo "Chosen directory empty" >&2
		return 1
	elif [[ ! -d "$chosen" ]]; then
		echo "$chosen is not a directory" >&2
		return 1
	fi

	cd "$chosen"
}
