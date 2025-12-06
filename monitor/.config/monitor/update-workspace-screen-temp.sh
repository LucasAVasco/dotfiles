#!/bin/bash
#
# Automatically disables GammaStep for work-spaces 1-5 and enables it for work-spaces 0, 6-10 and F1-F5.
#
# Usage: update-workspace-screen-temp.sh [-r] <work-space-number>
# -r: Reset screen temperature (useful if switching between TTYs).
# <work-space-number> is the work-space number. Supports the following work-spaces: 0, 1-5, F1-F5. Any other value results in undefined
# behavior.

set -e

source ~/.config/bash/libs/linux/session.sh

# Command line arguments
if [[ "$1" == '-r' ]]; then
	reset_screen_temp=y
	shift
fi
workspace="$1"

# Constants
warm="${WARM_TEMPERATURE:-3000}"

# Reset GammaStep and the screen temperature.
reset_gammastep() {
	pkill-wait -u "$USER" -f '^gammastep ' || true # Must not start a new instance if already running
	gammastep -x & # Reset
	sleep 0.1
	pkill-wait -u "$USER" -f '^gammastep ' || true
}

# Disable GammaStep if enabled.
disable_gammastep() {
	case $(linux_session_get_type) in
		xorg)
			# In Xorg, GammaStep is non-blocking. It just configures the temperature and exits
			gammastep -x
			;;

		wayland)
			# GammaStep runs in background on Wayland compositors (blocking operation). To disable it, we need to kill it
			pkill-wait -u "$USER" -f '^gammastep ' > /dev/null 2>&1 || true
			;;

		*)
			echo 'Unknown session type' >&2
			exit 1
			;;
	esac
}

# Enable GammaStep if disabled.
enable_gammastep() {
	case $(linux_session_get_type) in
		xorg)
			# In Xorg, GammaStep is non-blocking. It just configures the temperature and exits
			gammastep -P -O "$warm"
			;;

		wayland)
			# GammaStep runs in background on Wayland compositors (blocking operation)
			# INFO(LucasAVasco): must not start a new instance if already running. Otherwise, GammaStep will not release the resources and
			# you will not be able to change the color temperature until stop the compositor and restart it
			pgrep -u "$USER" -f '^gammastep ' > /dev/null 2>&1 || \
				gammastep -P -O "$warm" & disown
			;;

		*)
			echo 'Unknown session type' >&2
			exit 1
			;;
	esac
}

# Resets GammaStep
if [[ "$reset_screen_temp" == 'y' ]]; then
	reset_gammastep
fi

# Sets GammaStep according to the work-space number
first_char="${workspace:0:1}"
if [[ "$first_char" == "F" || "$first_char" == "f" ]]; then
	enable_gammastep
elif [[ "$workspace" -gt 5 || "$workspace" == 0 ]]; then
	enable_gammastep
else
	disable_gammastep
fi
