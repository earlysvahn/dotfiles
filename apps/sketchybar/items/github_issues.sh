#!/bin/sh

sketchybar --add item github_issues right

sketchybar --set github_issues \
  script="$PLUGIN_DIR/github_issues.sh" \
  click_script="$PLUGIN_DIR/github_issues_click.sh" \
  icon.font="$FONT:Regular:14.0" \
  padding_right=3 \
  label.font="$FONT:Bold:14.0" \
  label.drawing=on \
  update_freq=600 \
  background.drawing=on \
  background.padding_left=5 \
  background.padding_right=5
