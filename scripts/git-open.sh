#!/bin/bash
open_actions=false

while [ "$#" -gt 0 ]; do
	case "$1" in
	-a | --actions)
		open_actions=true
		shift
		;;
	-A)
		open_actions=true
		shift
		;;
	*)
		shift
		;;
	esac
done

repo_url=$(git config --get remote.origin.url)

if [ -n "$repo_url" ]; then
	if [ "$open_actions" = true ]; then
		github_actions_url="${repo_url%.git}/actions"
		open "$github_actions_url"
	else
		open "$repo_url"
	fi
else
	echo "Error: Not a Git repository or no remote URL configured."
fi
