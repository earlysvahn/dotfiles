#!/bin/bash

SSID=$(networksetup -listpreferredwirelessnetworks en0 | sed -n '2 p' | tr -d '\t')

if [ -z "$SSID" ]; then
   SSID="No Wi-Fi"
fi

sketchybar --set wifi \
   label="$SSID"
