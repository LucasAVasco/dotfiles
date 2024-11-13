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


set -e

# Xorg
if [[ -z "$WAYLAND_DISPLAY" ]]; then
	area=()
	if [[ $interactive == 'y' ]]; then
		area=(-g "$(slop)")
	fi

	if [[ $save2clipboard == 'y' ]]; then
		maim ${area[@]} | tee "$output_file" | ~/.config/clipboard/copy.sh --stdin -t image/png
	else
		maim ${area[@]} "$output_file"
	fi

# Wayland
else
	call_grim() {
		if [[ $interactive == 'y' ]]; then
			grim -g "$(slurp)" "$@"
		else
			grim "$@"
		fi
	}

	if [[ $save2clipboard == 'y' ]]; then
		call_grim - | tee "$output_file" | ~/.config/clipboard/copy.sh --stdin
	else
		call_grim "$output_file"
	fi
fi

notify-send "Screenshot take!" "Output file: '$output_file'"
