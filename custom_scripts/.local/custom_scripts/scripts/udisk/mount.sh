#!/bin/bash
#
# Mount some device with udisks.
#
# Dependencies:
# * udisks2
# * lsblk
# * fzf

set -e

source "$REPO_DIR/libs/tui.sh"

current_dir=$(realpath -m -- "$0/../")
source "$current_dir/lib/devices.sh"


# Shows the udisks status and lsblk output, so the user can see what devices can be mounted
"$current_dir/show_devices.sh"
echo -e "\n"

# Asks if the user want to mount something or abort
if [[ $(tui_ask_boolean 'Want to mount some device?' y) == 'n' ]]; then
	echo -e '\nOperation aborted...'
	exit 1
fi

# Asks the user by a device. Only search by devices without mount points ('^$' regex)
selected_device=$(get_devices_by_mount_point '^$' | tr ',' '\n' | fzf)

if [[ -z "$selected_device" ]]; then
	echo -e '\nDevice not selected. Aborting...'
	exit 1
fi

# Command to mount the device
cmd=(udisksctl mount)

# Asks if the user want to mount as another user
if [[ $(tui_ask_boolean 'Want to mount as another user?' n) == 'y' ]]; then
	user_name=$(tui_ask_input 'User name')
	cmd=(sudo -u "$user_name" -- "${cmd[@]}")
fi

# Sets if the user can send the root password to mount the device
allow_user_interaction=n

id_res=($(id))
[ "${id_res[0]}" == 'uid=0(root)' ] && allow_user_interaction=y  # Root and admin can do it
[ "${USER:0:5}" == 'admin' ] && allow_user_interaction=y

for group in $(groups); do  # Users with 'sudo' and 'wheel' can do it
	[ "$group" == 'sudo' -o "$group" == 'wheel' ] && allow_user_interaction=y
done

if [[ "$allow_user_interaction" == 'n' ]]; then
	cmd+=('--no-user-interaction')
fi

# Block device
cmd+=('-b' "/dev/$selected_device")

# Runs the command
"${cmd[@]}"

# Shows the udisks status and lsblk output after the changes
"$current_dir/show_devices.sh"
