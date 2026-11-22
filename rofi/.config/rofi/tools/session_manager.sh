#!/bin/bash
#
# Interface to manage the Bspwm session with Rofi. Interactively manage the session with Rofi


# Paths
current_dir=$(realpath -m -- "$0/../")


# Content to be displayed in Rofi (Nerd Font glyphs + labels, consistent with Quickshell)
buttons=(
	"<span font_desc='JetBrainsMono Nerd Font Propo 20'>󰐥</span>&#10;<span font_desc='Adwaita Sans 10'>Shutdown</span>"
	"<span font_desc='JetBrainsMono Nerd Font Propo 20'>󰜉</span>&#10;<span font_desc='Adwaita Sans 10'>Reboot</span>"
	"<span font_desc='JetBrainsMono Nerd Font Propo 20'>󰤄</span>&#10;<span font_desc='Adwaita Sans 10'>Suspend</span>"
	"<span font_desc='JetBrainsMono Nerd Font Propo 20'>󰋊</span>&#10;<span font_desc='Adwaita Sans 10'>Hibernate</span>"
	"<span font_desc='JetBrainsMono Nerd Font Propo 20'>󰌾</span>&#10;<span font_desc='Adwaita Sans 10'>Lock screen</span>"
	"<span font_desc='JetBrainsMono Nerd Font Propo 20'>󰍃</span>&#10;<span font_desc='Adwaita Sans 10'>Logout</span>"
)

content=$(printf '%s\n' "${buttons[@]}")

# Displays Rofi interface
selected_command=$(printf '%s' "$content" | rofi -dmenu -markup-rows -eh 2 -theme "$current_dir/themes/session_manager.rasi" -p 'Session')

# Executes the command
case "$selected_command" in
	# Shutdown
	*Shutdown* )
		shutdown now
	;;

	# Reboot
	*Reboot* )
		reboot
	;;

	# Suspend
	*Suspend* )
		systemctl suspend
	;;

	# Hibernate
	*Hibernate* )
		systemctl hibernate
	;;

	# Lock-screen
	*'Lock screen'* )
		~/.config/screenlocker/manager.sh run
	;;

	# Switch-user
	*Logout* )
		if [[ -n "$CUSTOM_DESKTOP_LOGOUT_COMMAND" ]]; then
			bash -c "$CUSTOM_DESKTOP_LOGOUT_COMMAND"
		fi
	;;
esac
