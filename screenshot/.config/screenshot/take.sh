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

source ~/.local/lib/dotfiles/bash/linux/session.sh

source ~/.local/lib/dotfiles/bash/linux/clipboard.sh

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
	folder="$HOME/Pictures/screenshots"
	mkdir -p "$folder"
	output_file="$folder/$(date '+%F_%Hh%Mmin%S').png"
fi

# Command to take a screenshot
screenshot_cmd=()

case $(linux_session_get_type) in
	x11)
		screenshot_cmd=(maim)
		if [[ $interactive == 'y' ]]; then
			screenshot_cmd+=(-g "$(slop)")
		fi

		;;

	wayland)
		screenshot_cmd=(grim)
		if [[ $interactive == 'y' ]]; then
			region=$(slurp -w 1 -f "%x %y %w %h")
			x=$(echo "$region" | cut -d ' ' -f 1)
			y=$(echo "$region" | cut -d ' ' -f 2)
			w=$(echo "$region" | cut -d ' ' -f 3)
			h=$(echo "$region" | cut -d ' ' -f 4)

			# Removes the border
			x=$((x+1))
			y=$((y+1))
			w=$((w-2))
			h=$((h-2))

			screenshot_cmd+=(-g "${x},${y} ${w}x${h}" -)
		else
			screenshot_cmd+=(-)
		fi
		;;

	*)
		echo "Unsupported session type: '$(linux_session_get_type)'" >&2
		exit 1
esac

# Takes the screenshot
if [[ $save2clipboard == 'y' ]]; then
	"${screenshot_cmd[@]}" | tee "$output_file" | ~/.config/clipboard/copy.sh --stdin -t image/png
else
	"${screenshot_cmd[@]}" > "$output_file"
fi

# Notifies
action_args=(--action=view=View --action=edit=Edit)
if [[ "$output_file" == /dev/null ]]; then
	action=$(notify-send "Screenshot take!" "Only copied to clipboard" ${action_args[@]})
	if [[ -n "$action" ]]; then
		image_file="$(mktemp --suffix=.png)"
		clip-paste -o "$image_file"
		trap "rm $image_file" EXIT
	fi
else
	action=$(notify-send "Screenshot take!" "Output file: '$output_file'" ${action_args[@]})
	image_file="$output_file"
fi

case "$action" in
	view)
		gthumb "$image_file"
		linux_clipboard_copy -t image/png < "$image_file"
		;;

	edit)
		gimp "$image_file"
		linux_clipboard_copy -t image/png < "$image_file"
		;;
esac
