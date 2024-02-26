#!/bin/bash
source ~/dotfiles/.env

# Set variables
TOKEN=$JOPLIN_ACCESS_TOKEN
JOPLIN_URL=$JOPLIN_URL

# Get all notes with specific fields
response=$(curl -sX GET "$JOPLIN_URL/notes?fields=title,is_todo,todo_completed&token=$TOKEN")
if [ -z "$response" ]; then
	echo "Failed to retrieve notes."
	exit 1
fi

# Filter notes where is_todo is 1 and todo_completed is larger than 0
filtered_notes=$(echo "$response" | jq -r '.items[] | select(.is_todo == 1 and .todo_completed <= 0) | .title')

# Print filtered titles
echo "Titles of completed todos:"
echo "$filtered_notes"
