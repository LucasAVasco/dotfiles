#!/bin/bash
#
# Power-off some device with udisks.
#
# Dependencies:
# * udisks2
# * lsblk
# * fzf

set -e

source ./lib/devices.sh
source ~/.local/lib/dotfiles/bash/dialog/dialog.sh
source ~/.local/custom_scripts/libs/scripts.sh
source ~/.local/custom_scripts/libs/scripts_run.sh

# Shows the udisks status and lsblk output, so the user can see what devices to power-off
scripts_run_script ./show_devices.sh
echo -e "\n"

# Asks if the user want power-off something or abort
if [[ $(dialog_ask_boolean 'Want to power-off some device?' 'y') == 'n' ]]; then
	echo -e '\nOperation aborted...'
	exit 1
fi

# Asks the user by a device. Can shutdown any device
selected_device=$(get_devices_by_mount_point '.*' | tr ',' '\n' | fzf)

if [[ -z "$selected_device" ]]; then
	echo -e '\nDevice not selected. Aborting...'
	exit 1
fi

# Ensures that user knows what device will be powered-off
if [[ $(dialog_ask_boolean "Want to power-off the '$selected_device' device?" 'y') == 'n' ]]; then
	echo -e '\nOperation aborted...'
	exit 1
fi

# Power-off the device
udisksctl power-off -b "/dev/$selected_device"

# Shows the udisks status and lsblk output after the changes
scripts_run_script ./show_devices.sh
