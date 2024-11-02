#!/bin/bash

# Define the path to pr_list.csv
PR_LIST_PATH="$HOME/tmp/pr_list.csv"

# Check if the pr_list.csv file exists
if [ ! -f "$PR_LIST_PATH" ]; then
  echo "PR list file not found at $PR_LIST_PATH"
  exit 1
fi

# Open choose with only the PR number and title visible, and capture the selected line
SELECTED=$(awk -F',' '{print $1}' "$PR_LIST_PATH" | choose)

# If a PR is selected, extract and open its URL
if [ -n "$SELECTED" ]; then
  # Find the corresponding URL from pr_list.csv
  URL=$(grep -F "$SELECTED" "$PR_LIST_PATH" | awk -F',' '{print $2}')
  open "$URL"
fi
