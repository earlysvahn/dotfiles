#!/usr/bin/env bash

export TMUX_CONFIG="$HOME/dotfiles/config/tmux/.tmux.conf"
t() {
        command tmux -f "$TMUX_CONFIG" "$@"
}

# List open tmux sessions
open_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

# Find directories and scripts to display
directories=$(find "$HOME/Development" "$HOME/private-dev" "$HOME/private-dev/nvim-plugins" "$HOME/Development/dooris-repo/apps" "$HOME/.config" "$HOME/dotfiles" "$HOME/dotfiles/scripts" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

# List script files separately to be included
scripts=$(find "$HOME/dotfiles/scripts" -type f -name "*.sh" 2>/dev/null)

# Combine the open sessions, directories, and scripts into the options
options=$(echo -e "$open_sessions\n$directories\n$scripts")

if [[ $# -eq 1 ]]; then
        selected=$1
else
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
    elif [ -f {} ]; then
        # Preview script contents
        head -n 20 {};
    else
        echo "No preview available.";
    fi' --header="Select a session, directory, or script" --preview-window=down:20:wrap)
fi

if [[ -z $selected ]]; then
        exit 0
fi

# If the selected item is a script, execute it
if [[ -f $selected && $selected == *.sh ]]; then
        bash "$selected"
        exit 0
fi

if echo "$open_sessions" | grep -q "^$selected$"; then
        # Attach or switch to the selected session
        if [[ -z $TMUX ]]; then
                t attach-session -t "$selected"
        else
                t switch-client -t "$selected"
        fi
        exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
        t new-session -s "$selected_name" -c "$selected" -n 'code' "nvim"
        exit 0
fi

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
        t new-session -ds "$selected_name" -c "$selected" -n 'code' "nvim"
fi

if [[ -z $TMUX ]]; then
        t attach-session -t "$selected_name"
else
        t switch-client -t "$selected_name"
fi
