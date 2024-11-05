#!/bin/sh

sketchybar --add item github_prs center

sketchybar --set github_prs \
  script="$PLUGIN_DIR/github_prs.sh" \
  click_script="$PLUGIN_DIR/github_prs_click.sh" \
  icon.font="$FONT:Regular:17.0" \
  label.font="$FONT:Bold:17.0" \
  label.drawing=on \
  update_freq=300 \
  updates=on \
  popup.drawing=on
