#!/bin/bash

# Function to move issues from board X to board Y
move_issues() {
	local from_board=""
	local to_board=""
	local issue_ids=()

	# Parse command line arguments
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--from)
			from_board="$2"
			shift 2
			;;
		--to)
			to_board="$2"
			shift 2
			;;
		--ids)
			IFS=',' read -r -a issue_ids <<<"$2"
			shift 2
			;;
		*)
			echo "Unknown option: $1"
			exit 1
			;;
		esac
	done

	# Check if all required arguments are provided
	if [[ -z "$from_board" || -z "$to_board" || ${#issue_ids[@]} -eq 0 ]]; then
		echo "Usage: move_issues --from <from_board> --to <to_board> --ids <issue_ids>"
		exit 1
	fi

	# Function to move an issue from board X to board Y
	move_issue() {
		local issue_number="$1"

		# Fetch issue details in JSON format
		local issue_details="$(gh issue view $issue_number --json title,body -q)"

		# Extract title and body from JSON
		local title="$(echo "$issue_details" | jq -r '.title')"
		local body="$(echo "$issue_details" | jq -r '.body')"

		echo $issue_details
		# Create the issue in board Y
		#gh issue create --title "$title" --body "$body" --project "$to_board"

		# Close the issue in board X
		# gh issue close $issue_number
	}

	# Move each issue from board X to board Y
	for issue_id in "${issue_ids[@]}"; do
		move_issue "$issue_id"
	done
}

# Call the function with command line arguments
move_issues "$@"
