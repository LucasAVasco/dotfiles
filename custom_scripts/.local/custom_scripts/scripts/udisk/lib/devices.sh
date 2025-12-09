#!/bin/bash
#
# Functions to work with udisks devices.

# Return the devices names separated by commas ','. Example: 'sda,sda1,sda2,sdb,sdb2'.
# Only return the device name if its mount point matches a provided regex.
#
# $1: Regex to match entry point.
get_devices_by_mount_point() {
	local device_names=''

	IFS=$'\n'
	for line in $(lsblk --raw --noheadings); do
		IFS=$' '
		local device_info=($line)
		local device_name=${device_info[0]}
		local device_mount_point=${device_info[6]}

		# Does not add devices that are already mounted
		if [[ "$device_mount_point" =~ $1 ]]; then
			device_names="$device_name,$device_names"
		fi
	done

	echo -en "$device_names"
}
