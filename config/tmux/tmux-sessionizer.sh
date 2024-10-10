#!/usr/bin/env bash

export TMUX_CONFIG="$HOME/dotfiles/config/tmux/.tmux.conf"
t() {
        command tmux -f "$TMUX_CONFIG" "$@"
}

# Get a list of existing tmux sessions
open_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

# Find new directories and add open sessions to the options list
directories=$(find "$HOME/Development" "$HOME/private-dev" "$HOME/private-dev/nvim-plugins" "$HOME/Development/dooris-repo/apps" "$HOME/.config" "$HOME/dotfiles" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

# Combine open sessions and directories into one list
options=$(echo -e "$open_sessions\n$directories")

# If a single argument is provided, use it directly
if [[ $# -eq 1 ]]; then
        selected=$1
else
        # Use fzf with enhanced preview logic
        selected=$(echo -e "$options" | fzf --preview '
    if [ -d {} ]; then
        # Preview file system for directories
        eza --icons --group-directories-first --git -la {} 2>/dev/null;
    elif tmux has-session -t {} 2>/dev/null; then
        # Preview tmux session details
        echo "Tmux Session: {}";
        echo "------------------------";
        tmux list-windows -t {} | sed "s/^/Window: /";
        echo "------------------------";
        echo "Pane Content Preview:";
        tmux list-panes -t {} -F "Pane #{pane_index} - Active Command: #{pane_current_command}";
        echo "------------------------";
        echo "Pane 0 Preview:";
        tmux capture-pane -t {}.0 -pS -50 2>/dev/null;
    else
        echo "No preview available.";
    fi' --header="Select a session or directory" --preview-window=down:20:wrap)
fi

# Exit if no selection is made
if [[ -z $selected ]]; then
        exit 0
fi

# Check if the selection is an open session or a directory
if echo "$open_sessions" | grep -q "^$selected$"; then
        # Attach or switch to the selected session
        if [[ -z $TMUX ]]; then
                t attach-session -t "$selected"
        else
                t switch-client -t "$selected"
        fi
        exit 0
fi

# Create a new session for the selected directory
selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# If no tmux session is running, create a new session and start vim
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
        # Create a new session and start vim
        t new-session -s "$selected_name" -c "$selected" -n 'vim' "nvim"
        exit 0
fi

# Create a detached session and start vim
if ! tmux has-session -t="$selected_name" 2>/dev/null; then
        # Create the session, but don't attach it, and start vim directly in the first window
        t new-session -ds "$selected_name" -c "$selected" -n 'vim' "nvim"
fi

# Attach to the new or existing session
if [[ -z $TMUX ]]; then
        t attach-session -t "$selected_name"
else
        t switch-client -t "$selected_name"
fi
