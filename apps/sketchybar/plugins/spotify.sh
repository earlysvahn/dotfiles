#!/bin/bash

# Check if Spotify is running
spotify_running=$(pgrep -x "Spotify")

if [ -z "$spotify_running" ]; then
  echo "Spotify is not running."
  sketchybar --set spotify drawing=off # Hide the item if Spotify is not running
  exit 0
else
  echo "Spotify is running."
fi

# Get the current player state and song details using AppleScript
spotify_info=$(osascript -e 'tell application "Spotify"
  if player state is playing then
    set track_name to name of current track
    set artist_name to artist of current track
    return artist_name & " - " & track_name
  else
    return "No song playing"
  end if
end tell')

# Print the current Spotify song information
echo "Spotify Info: $spotify_info"

# Update the Sketchybar item based on the song state
if [ "$spotify_info" == "No song playing" ]; then
  sketchybar --set spotify drawing=off # Hide the item if no song is playing
else
  sketchybar --set spotify drawing=on # Show the item if a song is playing
  sketchybar --set spotify label="$spotify_info"
fi
