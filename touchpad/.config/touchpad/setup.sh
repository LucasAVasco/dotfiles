#!/bin/bash
#
# Configure the touchpad to support tapping with one, two and triple fingers

source ~/.local/lib/dotfiles/bash/linux/session.sh

# Only works in Xorg
case "$(linux_session_get_type)" in
	x11)
		;;

	wayland)
		exit 0
		;;

	*)
		echo "Unknown session type: $(linux_session_get_type)" >&2
		exit 1
		;;
esac

# Get a input device id by the name
#
# $1: Device name
get_device_id()
{
	xinput list | grep "$1" | sed -n '1p' | sed 's/.*id=//' | sed 's/[ \t].*//'
}

# Get a input device option id by the option name
#
# $1: Device name
# $2: Device option name
get_device_option_id()
{
	local device_id=$(get_device_id "$1")

	# Doesn't return if there aren't this device
	if [ "$device_id" != '' ]; then
		option_line=$(xinput list-props "$device_id" | grep "$2" | sed -n '1p')

		# Doesn't return if this device hasn't this option
		if [ "$(echo "$option_line" | awk '/\(/')" != '' ]; then
			echo $option_line | sed 's/).*$//' | sed 's/^.*(//'
		fi
	fi
}

# Set a device option by the name
#
# $1: Device name
# $2: Device option name
# $3: Option value
set_device_option()
{
	local device_id=$(get_device_id "$1")
	if [ "$device_id" == '' ]; then
		echo "There aren't this device!" >&2
		return
	fi

	local option_id=$(get_device_option_id "$1" "$2")
	if [ "$option_id" == '' ]; then
		echo "There aren't this option!" >&2
		return
	fi

	xinput set-prop "$device_id" "$option_id" "$3"
}

# Enable Touchpad Tapping
if [[ "$(get_device_id 'Touchpad')" != '' ]]; then
	set_device_option 'Touchpad' 'libinput Tapping Enabled' '1'
fi
