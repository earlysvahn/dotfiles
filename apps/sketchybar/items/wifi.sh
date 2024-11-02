#!/bin/bash

wifi_item=(
  label.font="$FONT:Semibold:12"
  label.color=$WHITE
  icon.color=$WHITE
  icon.font="$FONT:Regular:14.0"
  icon.drawing=on
  y_offset=0
  padding_right=15
  script="$PLUGIN_DIR/wifi.sh" # Path to the Wi-Fi plugin script
  update_freq=120              # Update every 15 seconds
)

# Create the Wi-Fi item on the bar
sketchybar --add item wifi right \
  --set wifi "${wifi_item[@]}" \
  --subscribe wifi mouse.clicked
