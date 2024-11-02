#!/bin/bash

ISSUE_LIST_PATH="$HOME/tmp/issue_list.csv"

if [ ! -f "$ISSUE_LIST_PATH" ]; then
  echo "Issue list file not found at $ISSUE_LIST_PATH"
  exit 1
fi

SELECTED=$(awk -F',' '{print $1}' "$ISSUE_LIST_PATH" | choose)

if [ -n "$SELECTED" ]; then

  URL=$(grep -F "$SELECTED" "$ISSUE_LIST_PATH" | awk -F',' '{print $2}')
  open "$URL"
fi
