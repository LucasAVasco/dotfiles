#!/bin/bash
#
# Unmount some device with udisks.
#
# Dependencies:
# * udisks2
# * lsblk
# * fzf

set -e

source ./lib/devices.sh
source ~/.config/bash/libs/dialog/dialog.sh
source ~/.local/custom_scripts/libs/scripts.sh
source ~/.local/custom_scripts/libs/scripts_run.sh

# Shows the udisks status and lsblk output, so the user can see what devices can be unmounted
scripts_run_script ./show_devices.sh
echo -e "\n"

# Asks if the user want unmount something or abort
if [[ $(dialog_ask_boolean 'Want to unmount some device?' y) == 'n' ]]; then
	echo -e '\nOperation aborted...'
	exit 1
fi

# Asks the user by a device to unmount. Only search by devices with mount points in a media directory ('.*/media/' regex)
selected_device=$(get_devices_by_mount_point '/media/' | tr ',' '\n' | fzf)

if [[ -z "$selected_device" ]]; then
	echo -e '\nDevice not selected. Aborting...'
	exit 1
fi

udisksctl unmount -b "/dev/$selected_device"

# Asks if the user also want to power off the device
if [[ $(dialog_ask_boolean "Want to power-off the '$selected_device' device" 'n') == 'y' ]]; then
	udisksctl power-off -b "/dev/$selected_device"
else
	echo -en '\nThe device has not been powered-off. You need to powered-off the device before removing it!'
	echo -en '\nYou can use the "powered_off.sh" script.\n'
	exit 0
fi

# Shows the udisks status and lsblk output after the changes
scripts_run_script ./show_devices.sh
