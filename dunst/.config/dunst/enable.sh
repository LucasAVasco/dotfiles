#!/bin/bash


# Start/restart dunst
pkill-wait -u $UID dunst 2> /dev/null
nohup dunst > /dev/null &
