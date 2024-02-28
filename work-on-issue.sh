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

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	echo "Error: Not inside a Git repository. Aborting."
	exit 1
fi

issue=$(gh issue list --limit 200 | fzf --header "Select issue (Press 'Ctrl+D/esc' to quit)" --bind "ctrl-d:abort,esc:abort,ctrl-q:abort" | awk -F '\t' '{ print $1 }')

if [[ -z "$issue" ]]; then
	echo "Aborted."
	exit 1
fi

sanitized=$(gh issue view $issue --json "title" | jq -r ".title" | tr '[:upper:]' '[:lower:]' | tr -s -c "a-z0-9\n" "-" | head -c 60)
branchname=$issue-$sanitized
shortname=$(echo $branchname | head -c 30)

if [[ ! -z "$shortname" ]]; then
	git fetch
	existing=$(git branch -a | grep -v remotes | grep $shortname | head -n 1)
	if [[ ! -z "$existing" ]]; then
		sh -c "git switch $existing"
	else
		bold=$(tput bold)
		normal=$(tput sgr0)
		echo "${bold}Please confirm new branch name:${normal}"
		vared branchname
		#base=$(git branch --show-current)
		base=dev
		echo "${bold}Please confirm the base branch:${normal}"
		vared base
		if [[ -z "$base" ]]; then
			base=$(gh repo view --json defaultBranchRef --jq ".defaultBranchRef.name")
		fi
		git checkout -b $branchname origin/$base
		git push --set-upstream origin $branchname
	fi
fi
