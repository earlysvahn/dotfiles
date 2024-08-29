#!/bin/bash

# Function to get issues from a specific board within the organization "dooris-dev"
get_board_issues() {
	local org_name="dooris-dev"
	local board_name="$1"

	# Retrieve the board ID
	local board_id=$(gh api "/orgs/${org_name}/projects" | jq -r --arg board_name "$board_name" '.[] | select(.name == $board_name) | .id')

	# Check if the board exists
	if [[ -n "$board_id" ]]; then
		# Retrieve the column IDs for the board
		local column_ids=$(gh api "/projects/${board_id}/columns" | jq -r '.[].id')

		# Iterate through each column to get issues
		for column_id in $column_ids; do
			echo "Column ID: $column_id"
			gh api "/projects/columns/${column_id}/cards" | jq -r '.[].content_url'
		done
	else
		echo "Error: Board '$board_name' not found within organization '$org_name'."
		exit 1
	fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
	--board_name)
		board_name="$2"
		shift 2
		;;
	*)
		echo "Unknown option: $1"
		exit 1
		;;
	esac
done

# Check if board_name is provided
if [[ -z "$board_name" ]]; then
	echo "Usage: $0 --board_name <board_name>"
	exit 1
fi

# Call the function with the provided board name
get_board_issues "$board_name"
