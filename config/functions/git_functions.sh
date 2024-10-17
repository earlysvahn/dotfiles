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
    repo_directories=("$HOME/development" "$HOME/private-dev")

    # Color definitions using ANSI escape codes
    bg_green='\033[38;2;66;80;71m'  # #425047
    bg_red='\033[38;2;81;64;69m'    # #514045
    bg_blue='\033[38;2;58;81;93m'   # #3A515D
    fg='\033[38;2;211;198;170m'     # #D3C6AA
    red='\033[38;2;230;126;128m'    # #E67E80
    yellow='\033[38;2;219;188;127m' # #DBBC7F
    green='\033[38;2;167;192;128m'  # #A7C080
    reset='\033[0m'                 # Reset color

    # Function to update a Git repository
    update_git_repo() {
        repo="$1"
        cd "$repo" || return
        echo -e "${fg}Updating repository: $repo${reset}"

        # Save the current branch
        current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

        if [ $? -ne 0 ]; then
            echo -e "${red}Error: Not a valid Git repository at $repo${reset}"
            return
        fi

        # Determine the target branch: main-k8s for dooris-repo, otherwise main or master
        if [[ "$repo" =~ dooris-repo ]]; then
            target_branch="main-k8s"
        elif git show-ref --verify --quiet refs/heads/main; then
            target_branch="main"
        elif git show-ref --verify --quiet refs/heads/master; then
            target_branch="master"
        else
            echo -e "${red}No main or master branch found in $repo. Skipping...${reset}"
            return
        fi

        # Fetch changes quietly
        git fetch --quiet origin "$target_branch"

        # Check for uncommitted changes in the working tree
        if [ -z "$(git status --porcelain)" ]; then
            # Working tree is clean
            echo -e "${yellow}No local changes in $current_branch${reset}"

            # If the current branch is main, main-k8s, or master and has remote changes
            if [ "$current_branch" = "$target_branch" ]; then
                if [ "$(git log HEAD..origin/$target_branch --oneline)" ]; then
                    echo -e "${green}Remote changes detected, pulling updates...${reset}"
                    git pull origin "$target_branch"
                else
                    echo -e "${yellow}No remote changes in $target_branch.${reset}"
                fi
            fi
        else
            # There are local changes, skip pull
            echo -e "${red}Local changes detected in $current_branch, skipping pull.${reset}"
        fi

        cd - >/dev/null || return
    }

    # Main logic to find .git folders and update repositories
    for repo_directory in "${repo_directories[@]}"; do
        echo -e "${bg_blue}Checking repositories in: $repo_directory${reset}"

        for repo in "$repo_directory"/*; do
            if [ -d "$repo/.git" ]; then
                # If top-level has a .git folder, update the repository and skip subdirectories
                update_git_repo "$repo"
            else
                # No .git in the top-level directory, check subdirectories
                for sub_repo in "$repo"/*; do
                    if [ -d "$sub_repo/.git" ]; then
                        update_git_repo "$sub_repo"
                    fi
                done
            fi
        done
    done

    echo -e "${green}All repositories updated.${reset}"
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
