#!/bin/bash

source ~/.local/lib/dotfiles/bash/strict.sh

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

./keyboard.sh &

~/.config/touchpad/setup.sh &

./start-status-bar.sh &

./compositor.sh &

./screen-locker.sh &

./secrets-service.sh &

~/.config/docker/notify-running-containers.sh &
