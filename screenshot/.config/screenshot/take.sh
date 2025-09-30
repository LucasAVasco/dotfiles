#!/bin/bash
#
# Screenshot utility. Works in Xorg and Wayland.
#
# The screenshots are saved at '~/Pictures/' folder (this behavior can be overridden with the '-o|--output_file' option). You can select the
# area to grab with the '-i|-interactive' option. You can send the screenshot to the clipboard with the '-c|--clipboard' option.
#
# Example:
#
# `./take.sh -o out-file-name.png -i -c`: Takes an interactive screenshot, copy to clipboard and save to 'out-file-name.png'
#
# Dependencies:
# - tee
# - notify-send
# - maim (Xorg)
# - slop (Xorg, interactive screenshot)
# - grim (Wayland)
# - slurp (Wayland, interactive screenshot)
# - My 'clipboard/.config/clipboard/copy.sh' script (copy to clipboard)

source ~/.config/bash/libs/linux/session.sh

set -e

output_file=''
interactive='n'
save2clipboard='n'

while [[ $# -gt 0 ]]; do
	case "$1" in
		-o | --output_file )
			output_file="$2"
			shift
			;;

		-i | --interactive)
			interactive='y'
			;;

		-c | --clipboard )
			save2clipboard='y'
			;;

		*)
			echo "Unknow option: '$1'"
			exit 1
			;;
	esac

	shift
done

# Default values
if [[ -z "$output_file" ]]; then
	output_file="$HOME/Pictures/$(date '+%F_%Hh%Mmin%S').png"
fi

# Command to take a screenshot
screenshot_cmd=()

case $(linux_session_get_type) in
	xorg)
		screenshot_cmd=(maim)
		if [[ $interactive == 'y' ]]; then
			screenshot_cmd+=(-g "$(slop)")
		fi

		;;

	wayland)
		screenshot_cmd=(grim)
		if [[ $interactive == 'y' ]]; then
			screenshot_cmd+=(-g "$(slurp)" -)
		else
			screenshot_cmd+=(-)
		fi
		;;

	*)
		echo "Unknown session type: '$(linux_session_get_type)'" >&2
		exit 1
esac

# Takes the screenshot
if [[ $save2clipboard == 'y' ]]; then
	"${screenshot_cmd[@]}" | tee "$output_file" | ~/.config/clipboard/copy.sh --stdin -t image/png
else
	"${screenshot_cmd[@]}" > "$output_file"
fi

# Notifies
notify-send "Screenshot take!" "Output file: '$output_file'"
