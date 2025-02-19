#!/bin/sh

sketchybar --add item kube_crashloop center

sketchybar --set kube_crashloop \
  script="$PLUGIN_DIR/kube_crashloop.sh" \
  icon.font="$FONT:Regular:17.0" \
  label.font="$FONT:Bold:17.0" \
  label.drawing=on \
  update_freq=60 \
  background.drawing=on \
  background.padding_left=5 \
  background.padding_right=5
