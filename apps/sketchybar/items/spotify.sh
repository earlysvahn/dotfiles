#!/bin/bash

# Define the Spotify item settings
spotify_item=(
  label.font="$FONT:Semibold:12"  # Use a custom font for the label
  label.color=0xffdcdfe4          # Set label color
  y_offset=0                      # Y-axis offset for positioning
  padding_right=15                # Set padding on the right
  script="$PLUGIN_DIR/spotify.sh" # Call the updated spotify.sh script
  update_freq=5                   # Check every 5 seconds for updates
  drawing=on                      # Ensure drawing is set to on initially
)

# Create the Spotify item and set its properties
sketchybar --add item spotify center \
  --set spotify "${spotify_item[@]}" \
  --subscribe spotify mouse.clicked
