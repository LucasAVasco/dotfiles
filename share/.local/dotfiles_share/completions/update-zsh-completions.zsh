# Generate completion files to custom scripts and save it to './zsh/'.
#
# NOTE(LucasAVasco): This script must be sourced by a ZSH shell: `source ./update-zsh-completions.zsh`

# Directory with the completions files
current_dir=$(dirname `realpath "${(%):-%x}"`)
completions_dir="$current_dir/zsh"
mkdir -p "$completions_dir"

# Completion file of each command. Completions not starting with '_' will be treated as commands. This script will query the completion
# source from this command
declare -A cmd_completion_mapping
cmd_completion_mapping=(
	# [chdesk]=''
	# [cht-fzf]=''
	# [clip-clean]=''
	# [clip-copy]=''
	# [copy_cwd]=''
	# [default_file_manager]=''
	# [default_file_manager_synced]=''
	# [default_open]=''
	# [default_term]=''
	# [default_term_file_manager]=''
	# [default_term_synced]=''
	# [default_web_browser]=''
	# [git_show]=''
	# [git_show_new_term]=''
	# [my_notes]=''
	# [nvim-tmp]=''
	# [nvim_new_win]=''
	# [nvim_new_win_synced]=''
	# [rclone_web_gui]=''
	# [s-wait]=''
	# [screenshot-take]=''
	# [set_theme]=''
	# [tldr-fzf]=''
	# [trash-restore-from-can]=''
	[ag2nvim]='ag'
	[fd2nvim]='fd'
	[helm-kind]='helm'
	[kubectl-kind]='kind'
	[rg2delta]='rg'
	[rg2nvim]='rg'
	[trash]='rm'
	[s-wait]='_precommand'
)

for destiny_cmd completion in "${(@kv)cmd_completion_mapping}"; do
	if [[ "${completion[1]}" != '_' ]]; then
		completion="$_comps[$completion]"
	fi

	echo "$destiny_cmd -> $completion"

	cat << EOF > "$current_dir/zsh/_$destiny_cmd"
#compdef $destiny_cmd
compdef $completion $destiny_cmd
$completion
EOF
done

# Unset the variables. This script is sourced instead of executed, so the variables will not be automatically erased on exit
unset current_dir
unset completions_dir
unset cmd_completion_mapping
unset destiny_cmd completion
