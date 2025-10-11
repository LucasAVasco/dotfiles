# Clear history. There are a copy of the current history in the memory. So the user need to close all terminals and run it
# again to complete the remove
alias clear_history='echo "" > "$HISTFILE" && history -p'

# Alias to manage the dot files and custom scripts
alias dotfiles='make --quiet -C ~/.local/dotfiles SD=$(pwd) CD_SHELL=/bin/zsh'
alias dotfiles-cd='cd "$(dotfiles get-root-dir)"'
alias custom-script='make --quiet -C ~/.local/custom_scripts WORKING_DIR=$(pwd) CD_SHELL=/bin/zsh'
alias custom-script-cd='cd "$(custom-script get-root-dir)"'

# Applications
alias v='nvim'
alias c='code'
alias k='kubectl'
alias y='default_term_file_manager_cd'

# Overwrite default command line applications
alias mv='mv -i'
alias rm='rm -i'
alias cp='cp -i'
alias less='/bin/less --RAW-CONTROL-CHARS --clear-screen --quit-if-one-screen --chop-long-lines'
alias rlwrap='rlwrap --complete-filenames --case-insensitive'
