#!/bin/bash

# Check if there are any issues in the repository
has_issues=$(gh issue list --limit 1 | wc -l)
if [[ $has_issues -eq 0 ]]; then
	read -p "No issues found. Do you want to create a new issue? (y/n): " create_issue
	if [[ $create_issue == "y" ]]; then
		gh issue create
	else
		echo "Aborted."
		exit 1
	fi
fi

# Ensure inside a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	echo "Error: Not inside a Git repository. Aborting."
	exit 1
fi

# Select an issue
issue=$(gh issue list --limit 200 --json number,title | jq -r '.[] | "\(.number)\t\(.title)"' | sort -k1,1nr | fzf --header "Select issue (Press 'Ctrl+D/esc' to quit)" --bind "ctrl-d:abort,esc:abort,ctrl-q:abort" | awk -F '\t' '{ print $1 }')

if [[ -z "$issue" ]]; then
	echo "Aborted."
	exit 1
fi

# Ask if this is a fix or a feature, with default to 'feature'
read -p "Is this a 'fix' or a 'feature'? (default: feature): " type
type=${type:-feature} # Default to 'feature' if no input is provided

# Validate input
if [[ "$type" != "fix" && "$type" != "feature" ]]; then
	echo "Error: Invalid input. Please enter either 'fix' or 'feature'. Aborting."
	exit 1
fi

# Sanitize the branch name from the issue title
sanitized=$(gh issue view $issue --json "title" | jq -r ".title" | tr '[:upper:]' '[:lower:]' | tr -s -c "a-z0-9\n" "-" | head -c 60)
branchname="$type/$issue-$sanitized"

# Limit the branch name to 30 characters
shortname=$(echo $branchname | head -c 30)

# Switch to main branch and pull latest changes
git checkout main
git pull origin main

# Check if shortname is valid
if [[ ! -z "$shortname" ]]; then
	git fetch
	existing=$(git branch -a | grep -v remotes | grep $shortname | head -n 1)
	if [[ ! -z "$existing" ]]; then
		# Switch to existing branch if it already exists
		sh -c "git switch $existing"
	else
		# Ask for confirmation of branch name, use issue number if no input
		read -p "Please confirm the new branch name (default: $branchname): " user_branchname
		branchname=${user_branchname:-$branchname}

		# Checkout new branch from main
		git checkout -b $branchname main
		git push --set-upstream origin $branchname
	fi
fi
