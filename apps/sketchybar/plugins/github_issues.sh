#!/bin/bash

ISSUE_LIST_PATH="$HOME/tmp/issue_list.csv"

mkdir -p "$HOME/tmp"

ISSUE_DATA=$(gh search issues --assignee=@me --state=open --json number,title,repository,url)
ISSUE_COUNT=$(echo "$ISSUE_DATA" | jq '. | length')
ISSUE_DETAILS=$(echo "$ISSUE_DATA" | jq -r '.[] | "#\(.number) \(.title) (\(.repository.name)),\(.url)"')

echo "$ISSUE_DETAILS" >"$ISSUE_LIST_PATH"

if [ "$ISSUE_COUNT" -lt 1 ]; then
  ICON="􀀀"
  ICON_COLOR="0xffffffff" # White
elif [ "$ISSUE_COUNT" -le 3 ]; then
  ICON="􁹮"
  ICON_COLOR="0xffffffff" # Yellow
else
  ICON="􀀁"
  ICON_COLOR="0xffff0000" # Red
fi

sketchybar --set github_issues icon.color="$ICON_COLOR" icon="$ICON" label="$ISSUE_COUNT"
