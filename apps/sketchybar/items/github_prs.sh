#!/bin/sh

sketchybar --add item github_prs right

sketchybar --set github_prs \
  script="$PLUGIN_DIR/github_prs.sh" \
  click_script="$PLUGIN_DIR/github_prs_click.sh" \
  icon.font="$FONT:Regular:14.0" \
  padding_left=3 \
  label.font="$FONT:Bold:14.0" \
  label.drawing=on \
  update_freq=300 \
  updates=on \
  popup.drawing=on
