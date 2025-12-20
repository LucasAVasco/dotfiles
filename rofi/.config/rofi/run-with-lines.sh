#!/bin/bash
#
# Run Rofi with a specific number of lines in the list.
#
# $1: number of lines
# $2...: Rofi options

rofi -theme-str "listview { lines:$1;}" "${@:2}"
