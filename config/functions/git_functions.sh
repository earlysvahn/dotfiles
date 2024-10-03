#!/bin/bash

# Clone repository into the development directory or current directory if -c is used
clonerepo() {
    local dir="$HOME/development" # Default directory

    while getopts "c" opt; do
        case $opt in
        c)
            dir="$PWD" # Set directory to current directory if -c flag is used
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            return 1
            ;;
        esac
    done

    shift $((OPTIND - 1))

    if [ -z "$1" ]; then
        echo "Usage: clonerepo [-c] <repo-name>"
    else
        git clone "https://github.com/dooris-dev/$1.git" "$dir/$1"
    fi
}

# Add all changes, commit with a message, and push to the remote repository
gitpush() {
    git add -A && git commit -m "$1" && git push
}

# Pull the latest changes from all repositories in the development directory
getall() {
    repo_directory="$HOME/development"
    green='\033[0;32m'
    red='\033[0;31m'
    yellow='\033[0;33m'
    reset='\033[0m'
    cd "$repo_directory" || return

    for repo in */; do
        cd "$repo" || continue
        echo "Updating repository: $repo"
        if [ "$repo" = "dooris-repo/" ]; then
            git pull origin main-k8s
        else
            git pull origin main
        fi
        cd ..
    done
}

# Open current repo in GitHub, or the actions page if specified
gopen() {
    bash $HOME/dotfiles/scripts/git-open.sh
}

# GitHub Issue Management
issue() {
    local issue_number="$1"
    local action="$2"
    local temp_file="/tmp/issue_description_${issue_number}.txt"

    select_issue() {
        local issue_list=$(gh issue list --limit 50 --json number,title | jq -r '.[] | "\(.number): \(.title)"')
        issue_number=$(echo "$issue_list" | fzf --prompt="Select an issue: " | cut -d':' -f1)

        if [[ -z "$issue_number" ]]; then
            echo "No issue selected."
            return 1
        fi
    }

    if [[ -z "$issue_number" ]]; then
        select_issue
        if [[ $? -ne 0 ]]; then
            return 1
        fi
    fi

    if [[ -z "$action" ]]; then
        echo "Choose action: (v)iew / (c)omment / (e)dit"
        read -r action
    fi

    if [[ "$action" == "v" || "$action" == "--view" ]]; then
        gh issue view "$issue_number"
        return
    fi

    if [[ "$action" == "c" || "$action" == "--comment" ]]; then
        echo -e "@kjbakke @RobinGranqvistEB @storm84\n" >"$temp_file"
        nvim +2 "$temp_file"
        printf "Do you want to comment on issue $issue_number? (y/n): "
        read answer
        if [ "$answer" = "y" ]; then
            gh issue comment "$issue_number" --body "$(cat "$temp_file")"
            echo "Comment added to issue $issue_number."
        else
            echo "No comment was added to issue $issue_number."
        fi
        return
    fi

    if [[ "$action" == "e" || "$action" == "--edit" ]]; then
        local issue_description=$(gh issue view "$issue_number" --json "body" 2>/dev/null | jq -r ".body")
        echo "$issue_description" >"$temp_file"
        nvim "$temp_file"
        printf "Do you want to update the issue with the modified description? (y/n): "
        read answer
        if [ "$answer" = "y" ]; then
            gh issue edit "$issue_number" --body "$(cat "$temp_file")"
            echo "Issue $issue_number updated successfully."
        else
            echo "No changes were made to issue $issue_number."
        fi
        return
    fi
}

# Rebase function
rebase() {
    local base_branch="main"
    case "$1" in
    "main")
        base_branch="main"
        ;;
    "k8s")
        base_branch="main-k8s"
        ;;
    *)
        base_branch="$1"
        ;;
    esac
    local current_branch=$(git rev-parse --abbrev-ref HEAD)

    if [ "$current_branch" = "$base_branch" ]; then
        echo "🔄 You are already on the $base_branch branch"
        git pull
        return 0
    fi

    git checkout $base_branch
    git pull
    git checkout -
    git rebase "$base_branch" || echo "Rebase failed. Resolve conflicts manually."
}

# Pull Request Management
dpd() { gh pr comment "$1" --body ".deploy dev"; }
dpt() { gh pr comment "$1" --body ".deploy test"; }
dps() { gh pr comment "$1" --body ".deploy stage"; }
pr() {
    local base_branch="main"
    case "$1" in
    "main") base_branch="main" ;;
    "k8s") base_branch="main-k8s" ;;
    *) base_branch="$1" ;;
    esac
    gh pr create --base "$base_branch" --head "$(git branch --show-current)"
}
