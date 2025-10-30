#!/bin/bash

# Markup
notify-send -u critical -A action=response Summaty "<h1>Header</h1>" &

sleep 0.5

# Multiple actions, long summary and body
notify-send -u low -i btop \
	-A action0=response0 \
	-A action1=response1 \
	-A action2=response2 \
	-A action3=response3 \
	-A action4=response4 \
	-A action5=response5 \
	-A action6=response6 \
	-A action7=response7 \
	-A action8=response8 \
	-A action9=response9 \
	-A action10=response10 \
	-A action11=response11 \
	-A action12=response12 \
	-A action13=response13 \
"Very long summary, Very long summary, Very long summary, Very long summary, Very long summary" \
"Line 0 is a very long line, is a very long line, is a very long line, is a very long line, is a very long line
Line 1
Line 2
Line 3
Line 4
Line 5
Line 6
Line 7
Line 8
Line 9
Line 10
Line 11
Line 12
" &

sleep 0.5

# Notification with inline reply
gdbus call --session \
	--dest org.freedesktop.Notifications \
	--object-path /org/freedesktop/Notifications \
	--method org.freedesktop.Notifications.Notify \
	"App name" 0 "" "Summary of a inline reply action" "Body of a inline reply notification" \
	"[ 'inline-reply', 'Reply' ]" \
	"{ 'urgency': <uint32 1> }" 15
