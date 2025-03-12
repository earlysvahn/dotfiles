#!/bin/bash

INPUT_SOURCE=(
  update_freq=5
  icon.drawing=off
  script="$PLUGIN_DIR/get_input_source"
)

sketchybar --add item input_source right \
  --set input_source "${INPUT_SOURCE[@]}"
