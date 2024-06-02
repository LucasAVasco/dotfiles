#!/bin/bash


# #region User defined colors

color_status_win_bg='color242'
color_status_win_fg='color15'

color_status_win_current_bg='color253'
color_status_win_current_fg='color236'

color_status_bg='color237'
color_status_bell='color196'
color_status_current='color15'
color_status_last='color77'
color_status_activity='color220'

color_clock='color242'

color_pane='color246'
color_pane_active='color15'

color_message_bg='color252'
color_message_fg='color237'
color_message_vi_normal_bg='color222'
color_message_vi_normal_fg='color237'

color_left_bg='color252'
color_left_fg='color239'

color_left_prefix_bg='color214'
color_left_prefix_fg='color255'

color_right_bg='color252'
color_right_fg='color240'
color_right_icon_fg='color15'
color_right_uptime='color208'
color_right_time='color70'
color_right_day='color202'

color_copy_match_bg='color226'
color_copy_match_fg='color16'
color_copy_current_match_bg='color196'
color_copy_current_match_fg='color15'
color_copy_mark_bg='color16'
color_copy_mark_fg='color226'

# #endregion


# #region Functions to set the options

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


# Add a separator that changes the background and foreground color. This separator will be printed with its foreground color
# equal to the new background color. Because of it, you can use full filled characters as separators, e.g. 
#
# $1: separator
# $2: new background color
# $3: new foreground color
add_solid_separator() {
	echo -en "#[fg=${2}]${1}#[bg=${2}]#[fg=${3}]"
}

# #endregion


# #region General options

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
set_option copy-mode-match-style bg=${color_copy_match_bg},fg=${color_copy_match_fg}
set_option copy-mode-mark-style bg=${color_copy_mark_bg},fg=${color_copy_mark_fg}
set_option copy-mode-current-match-style bg=${color_copy_current_match_fg},fg=${color_copy_current_match_bg}

# Message
set_option message-style bg=${color_message_bg},fg=${color_message_fg}
set_option message-command-style bg=${color_message_vi_normal_bg},fg=${color_message_vi_normal_fg}  # VI normal mode inside command mode

# #endregion


# #region Status bar

set_option status on  # Show status bar
set_option status-interval 10
set_option status-position bottom
set_option status-justify left  # Window list justification in the status bar
set_option status-style bg=${color_status_bg}

# Status left
set_option status-left-style bg=${color_status_bg}
set_option status-left "#{?client_prefix,#[fg=${color_left_prefix_bg}],#[fg=${color_left_bg}]} "
append_option status-left "#{?client_prefix,#[bg=${color_left_prefix_bg}],#[bg=${color_left_bg}]}"
append_option status-left "#{?client_prefix,#[fg=${color_left_prefix_fg}],#[fg=${color_left_fg}]} #S"
append_option status-left "#{?client_prefix,#[fg=${color_left_prefix_bg}],#[fg=${color_left_bg}]}"
append_option status-left "#[bg=${color_status_bg}]"
append_option status-left "#{?client_prefix,#[fg=${color_left_prefix_bg}],#[fg=${color_left_bg}]} "

# Window in the status bar
set_option window-status-activity-style fg=${color_status_activity}
set_option window-status-current-style fg=${color_status_current}
set_option window-status-bell-style fg=${color_status_bell}
set_option window-status-last-style fg=${color_status_last}

status_flags=''  # Custom window flags to be added to a window status
status_flags+='#{?window_start_flag,󰩀 ,}'
status_flags+='#{?window_activity_flag,󰜎 ,}'
status_flags+='#{?window_bell_flag,󰂚 ,}'
status_flags+='#{?window_last_flag,󰒮 ,}'
status_flags+='#{?window_marked_flag,󰄲 ,}'
status_flags+='#{?window_silence_flag,󱙍 ,}'
status_flags+='#{?window_zoomed_flag,🔍 ,}'
status_flags+='#{?wrap_flag,,}'
status_flags+='#{?window_end_flag,󰨿 ,}'

set_option window-status-current-format "█"
append_option window-status-current-format "#[fg=${color_status_win_current_fg}]#[bg=${color_status_win_current_bg}] #I #W ${status_flags}"
append_option window-status-current-format "#[fg=${color_status_win_current_bg}]#[bg=${color_status_bg}]"

set_option window-status-format "█"
append_option window-status-format "#[fg=${color_status_win_fg}]#[bg=${color_status_win_bg}] #I #W ${status_flags}"
append_option window-status-format "#[fg=${color_status_win_bg}]#[bg=${color_status_bg}]"

set_option window-status-separator ' '


# #region Status right

# Add a new element to the right status bar. It is required to provide an icon (and its color) to be placed before the element content.
#
# $1: Icon
# $2: Icon color
# $3: content
add_status_right_element() {
	defalt_status_right_style="#[bg=${color_right_bg}]#[fg=${color_right_fg}]"  # The content will be shown with this style

	append_option status-right "$(add_solid_separator  $2 ${color_right_icon_fg})$1${defalt_status_right_style}"
	append_option status-right "$3"
	append_option status-right "#[bg=${color_status_bg}]#[fg=${color_right_bg}] "
}

set_option status-right-length 50
set_option status-right ''  # Clears the right status bar

# The command 'uptime' prints some information including how long the system is running. The first 'cut' selects only this information.
# Se the second 'cut' removes a comma at the end.
add_status_right_element '󰜎 ' ${color_right_uptime} ' #(uptime | cut -f 4-5 -d " " | cut -f 1 -d ",")'
add_status_right_element  '󱎫 ' ${color_right_time} ' %H:%M'       # Time
add_status_right_element  '󰃶 ' ${color_right_day} ' %a %Y/%m/%d'  # Date: week day, Year, Month, Day

# #endregion

# #endregion
