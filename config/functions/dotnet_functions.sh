#!/bin/bash

# Function to run dotnet projects using fzf
function dotnet_run_fzf() {
    local project=$(find . -name "*.csproj" -o -name "*.fsproj" | fzf)
    if [[ -n "$project" ]]; then
        dotnet run --project "$project"
    else
        echo "No project selected."
    fi
}
