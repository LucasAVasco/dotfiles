#!/bin/bash
#
# Functions related to OS architecture.

linux_arch_amd64='amd64'
linux_arch_arm32='arm32'
linux_arch_arm64='arm64'

# Return the current OS architecture.
#
# Return one of: 'amd64', 'arm32', 'arm64'
linux_arch_get() {
	local uname_res=$(uname -m)

	local arch
	case "$uname_res" in
		x86_64)
			arch="$linux_arch_amd64"
			;;

		arm64 | aarch64)
			arch="$linux_arch_arm64"
			;;

		*)
			# `uname` returns the arm32 architecture as 'arm<something>'
			if [[ "$uname_res" =~ ^arm.*$ ]]; then
				arch="$linux_arch_arm32"
			else
				echo 'Error: can not find the architecture!\n' >&2
				return
			fi
			;;
	esac

	echo -n "$arch"
}
