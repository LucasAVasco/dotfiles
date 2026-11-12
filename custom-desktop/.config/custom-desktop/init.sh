#!/bin/bash

source ~/.local/lib/dotfiles/bash/strict.sh

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

./start-status-bar.sh

./compositor.sh

~/.config/screenlocker/manager.sh enable --no-notify &

./secrets-service.sh &

~/.config/docker/notify-running-containers.sh &
