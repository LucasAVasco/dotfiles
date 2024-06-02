#!/bin/bash


# 'grep' command
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'


# 'ls' command
alias ls='ls --color=auto'
alias ll='ls --color=auto -lAFh'


# 'alert' alias. The notification summary (see 'man notify-send') will be the formatted history entry. Format the last history
# entry (tail -n1) by remove every character from the start of the line to the  character (with 'sed' command)
alias alert='notify-send $([ $? = 0 ] && echo --urgency=low -i terminal || echo --urgency=critical -i state-error) "$(history|tail -n1| sed -e 's/^[^]*//g')"'


# Move to the parent directory. The ';' allows to execute the command in the same line by separating it with a space.
# Example: '.. ..' will be executed as 'cd ..; cd ..' and the current directory will be the parent directory of the parent directory
alias ..='cd ..;'


# Exit terminal with ':q' like vim
alias :q='exit'


# Clear history. There are a copy of the current history in the memory. So the user need to close all terminals and run it
# again to complete the remove
alias clear_history='> ~/.bash_history && history -c'

# Alias manage the dot files
alias dotfiles='make -C ~/.local/dotfiles SD=$(pwd)'
