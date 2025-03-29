#!/bin/bash
#
# Library to manage my keyboard sound emulator.
#
# THe configurations are stored at '~/.config/keyboard/' directory.

linux_keyboard_sound_emulator_script=~/.config/keyboard/sound_emulator.sh

# Call the sound emulator script.
#
# $@: parameters passed to the script.
linux_keyboard_sound_emulator_call() {
	"$linux_keyboard_sound_emulator_script" "$@"
}

# Disable keyboard sound emulator until the scripts ends.
linux_keyboard_sound_emulator_disable_until_end() {
	if [[ $(~/.config/keyboard/sound_emulator.sh is-active) == y ]]; then
		"$linux_keyboard_sound_emulator_script" stop
		trap "$linux_keyboard_sound_emulator_script start" EXIT
	fi
}
