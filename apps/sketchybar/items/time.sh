#!/bin/bash

TIME=(
  update_freq=10
  icon.drawing=off
  script="$PLUGIN_DIR/time.sh"
)

sketchybar --add item time right \
  --set time "${TIME[@]}"
