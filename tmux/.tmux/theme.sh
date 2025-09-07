#!/bin/bash


# User defined colors {{{

color_status_line_bg='terminal'
color_status_bar_bg='terminal'

color_window_number_fg='#393c51'
color_window_name_bg='#393c51'
color_window_status_inactive='#999999'
color_window_status_current='#8888ff'
color_window_status_last='#b8b884'
color_window_status_bell='#cc2222'
color_window_status_activity='#d1af52'
color_window_separator='#393c51'

color_clock='#eeaa00'

color_pane='#aaaaaa'
color_pane_active='#eeaa00'

color_message_bg='#ddaa00'
color_message_fg='#000000'
color_message_vi_normal_bg='#eeaa00'
color_message_vi_normal_fg='#000000'

# Left status
color_left_bg='#2e303d'
color_left_fg='#aaaaaa'
color_left_prefix_bg='#ffaa00'
color_left_prefix_fg='#000000'

# Right status
color_right_bg='#2e303d'
color_right_fg='#aaaaaa'
color_right_separator='#393c51'
color_right_uptime='#efd378'
color_right_hostname='#18c6e9'

# Copy mode
color_mode_bg='#ddaa66'
color_mode_fg='#000000'
color_copy_match_bg='#ffaa00'
color_copy_match_fg='#333333'
color_copy_current_match_bg='#cc4400'
color_copy_current_match_fg='#000000'
color_copy_mark_bg='#00bbbb'
color_copy_mark_fg='#444444'

# }}}


# Functions to set the options {{{

# Set a global Tmux option
#
# $1: option name
# $2...$N: option value. All values are joined by spaces as a unique option value
set_option() {
	tmux set-option -g ${1} "${@:2}"
}


# Append to a global Tmux option
#
# $1: option name
# $2...$N: option value. All values are joined by spaces as a unique option value
append_option() {
	tmux set-option -ga ${1} "${@:2}"
}

# }}}


# General options {{{

# Clock mode
set_option clock-mode-colour ${color_clock}

# Display panes command (shows the pane number on the pane)
set_option display-panes-active-colour ${color_pane_active}
set_option display-panes-colour ${color_pane}

# Pane options
set_option pane-active-border-style fg=${color_pane_active}
set_option pane-border-style fg=${color_pane}
set_option pane-border-lines heavy

# set_option pane-border-status top  # This uses one more line to draw the pane status
set_option pane-border-format ' #{pane_index}: #{pane_title} (#{pane_current_command})'  # Only shown if the pane status is active

# Copy mode
set_option mode-style bg=${color_mode_bg},fg=${color_mode_fg}
set_option copy-mode-match-style bg=${color_copy_match_bg},fg=${color_copy_match_fg}
set_option copy-mode-mark-style bg=${color_copy_mark_bg},fg=${color_copy_mark_fg}
set_option copy-mode-current-match-style bg=${color_copy_current_match_fg},fg=${color_copy_current_match_bg}

# Message
set_option message-style bg=${color_message_bg},fg=${color_message_fg}
set_option message-command-style bg=${color_message_vi_normal_bg},fg=${color_message_vi_normal_fg}  # VI normal mode into Tmux command mode

# }}}


# Status bar {{{

set_option status on  # Show status bar
set_option status-interval 10   # Seconds
set_option status-position top
set_option status-justify left  # Window list justification in the status bar
set_option status-style bg=$color_status_bar_bg

# Status left
set_option status-left-length 15
set_option status-left-style bg=$color_status_line_bg
set_option status-left "#[bg=$color_status_line_bg]  "
append_option status-left "#{?client_prefix,#[fg=${color_left_prefix_bg}],#[fg=${color_left_bg}]}"
append_option status-left "#{?client_prefix,#[bg=${color_left_prefix_bg}],#[bg=${color_left_bg}]}"
append_option status-left "#{?client_prefix,#[fg=${color_left_prefix_fg}],#[fg=${color_left_fg}]}  #S "
append_option status-left "#{?scroll_position, copy,}"
append_option status-left "#[fg=$color_window_separator]#[bg=$color_status_bar_bg] "

# Window in the status bar
set_option window-status-style fg=${color_window_status_inactive},bg=${color_window_status_inactive}
set_option window-status-activity-style fg=${color_window_status_activity},bold,bg=${color_window_status_activity}
set_option window-status-current-style fg=${color_window_status_current},bold,bg=${color_window_status_current}
set_option window-status-bell-style "fg=${color_window_status_bell},bold,bg=${color_window_status_bell}"
set_option window-status-last-style fg=${color_window_status_last},bold,bg=$color_window_status_last

status_flags=''  # Custom window flags to be added to a window status
status_flags+='#{?window_activity_flag, 󰜎,}'
status_flags+='#{?window_bell_flag, 󰂚,}'
status_flags+='#{?window_marked_flag, ,}'
status_flags+='#{?window_silence_flag, 󰝟,}'
status_flags+='#{?window_zoomed_flag, 󰈈,}'
status_flags+='#{?wrap_flag,,}'

add_window_num() {
	echo -n "#[bg=$color_status_bar_bg]#[bg=default, fg=$color_window_number_fg] #I #[fg=default,bg=$color_window_name_bg]#[fg=default]"
}

end_window() {
	echo -n "#[fg=$color_window_name_bg,bg=$color_status_bar_bg]#[fg=default]"
}

set_option window-status-current-format "$(add_window_num) #W${status_flags} $(end_window)"
set_option window-status-format "$(add_window_num) #W${status_flags} $(end_window)"

set_option window-status-separator ''


# Status right {{{

# Add a new element to the right status bar. It is required to provide an icon (and its color) to be placed before the element content.
#
# $1: Icon
# $2: Icon color
# $3: content
add_status_right_element() {
	append_option status-right "#{?client_prefix,#[fg=${color_left_bg}],#[fg=$2]}#[bold]$1$3"
}

add_status_right_separator() {
	append_option status-right "#[fg=${color_right_separator}]  "
}

set_option status-right-length 50
set_option status-right "#{?client_prefix,#[fg=${color_left_prefix_bg}],#[fg=${color_left_bg}]}"
append_option status-right "#{?client_prefix,#[bg=${color_left_prefix_bg}],#[bg=${color_left_bg}]} "

# The command 'uptime' prints some information including how long the system is running. The first 'cut' selects only this information.
# Se the second 'cut' removes a comma at the end.
add_status_right_element '' ${color_right_uptime} ' #(uptime | cut -f 4-5 -d " " | cut -f 1 -d ",")'
add_status_right_separator
add_status_right_element '' ${color_right_hostname} ' #H'

append_option status-right " #{?client_prefix,#[fg=${color_left_prefix_bg}],#[fg=${color_left_bg}]}#[bg=$color_status_line_bg]  "

# }}}

# }}}
