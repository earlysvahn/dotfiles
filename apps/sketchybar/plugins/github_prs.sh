#!/bin/bash

# Define the path to pr_list.csv in the $HOME/tmp directory
PR_LIST_PATH="$HOME/tmp/pr_list.csv"

# Ensure the $HOME/tmp directory exists
mkdir -p "$HOME/tmp"

# Fetch PR details and calculate the count in a single call
PR_DATA=$(gh search prs --review-requested=@me --state=open --json number,title,repository,url)

# Calculate PR count using jq
PR_COUNT=$(echo "$PR_DATA" | jq '. | length')

# Format PR details for CSV output without the URL in the displayed part
PR_DETAILS=$(echo "$PR_DATA" | jq -r '.[] | "#\(.number) \(.title) (\(.repository.name)),\(.url)"')

# Overwrite the CSV file with the latest PR data
echo "$PR_DETAILS" >"$PR_LIST_PATH"

# Set icon color based on PR count
if [ "$PR_COUNT" -lt 1 ]; then
  ICON="􀂒"
  ICON_COLOR="0xffffffff" # White
elif [ "$PR_COUNT" -le 3 ]; then
  ICON="􀚓"
  ICON_COLOR="0xffffffff" # Yellow
else
  ICON="􀂓"
  ICON_COLOR="0xffff0000" # Red
fi

# Update SketchyBar with the icon color and PR count label
sketchybar --set github_prs icon.color="$ICON_COLOR" icon="$ICON" label="$PR_COUNT"
