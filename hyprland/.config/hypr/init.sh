#!/bin/bash

# Status bar
~/.config/custom-desktop/start-status-bar.sh

# Screen locker
~/.config/screenlocker/manager.sh enable --no-notify &

# Secrets service
~/.config/custom-desktop/secrets-service.sh &

# Shows a message if there are running Docker containers
~/.config/docker/notify-running-containers.sh &
