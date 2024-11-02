#!/bin/sh

# hangul and english item

plist_data=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources)
current_input_source=$(echo "$plist_data" | plutil -convert xml1 -o - - | grep -A1 'KeyboardLayout Name' | tail -n1 | cut -d '>' -f2 | cut -d '<' -f1)
echo "Current Input Source: $current_input_source" # Print the current input source for debugging

if [ "$current_input_source" = "ABC" ]; then
  sketchybar --set input_source label="EN"
else
  sketchybar --set input_source label="SV"
fi
