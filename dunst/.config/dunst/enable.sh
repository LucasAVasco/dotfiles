#!/bin/bash


# Start/restart dunst
pkill -u $UID dunst 2> /dev/null
nohup dunst > /dev/null &
