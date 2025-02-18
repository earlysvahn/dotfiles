#!/bin/zsh

SESSION_NAME="monitor-k9s"

# Ensure required environment variables are set
if [[ -z "$GCP_DEV_CONTEXT" || -z "$GCP_TEST_CONTEXT" || -z "$GCP_STAGE_CONTEXT" || -z "$GCP_PROD_CONTEXT" ]]; then
    echo "Error: One or more GCP context variables are not set!"
    exit 1
fi

# Check if the session already exists
tmux has-session -t "$SESSION_NAME" 2>/dev/null

if [[ $? != 0 ]]; then
    # Start a new tmux session (detached)
    tmux new-session -d -s "$SESSION_NAME"

    # Temporarily change prefix to C-a (instead of default C-b)
    tmux set-option -t "$SESSION_NAME" prefix C-a

    # Split window into 2 vertical panes (left/right)
    tmux split-window -h

    # Split both panes into top/bottom
    tmux select-pane -t 0
    tmux split-window -v
    tmux select-pane -t 2
    tmux split-window -v

    # Send k9s command to each pane with the correct GCP context
    tmux send-keys -t 0 "k9s --context=$GCP_PROD_CONTEXT" C-m
    tmux send-keys -t 1 "k9s --context=$GCP_STAGE_CONTEXT" C-m
    tmux send-keys -t 2 "k9s --context=$GCP_TEST_CONTEXT" C-m
    tmux send-keys -t 3 "k9s --context=$GCP_DEV_CONTEXT" C-m

    # Small delay to let k9s load before sending Ctrl+Z
    sleep 5

    # Send Ctrl+Z to each pane
    tmux send-keys -t 0 C-z
    tmux send-keys -t 1 C-z
    tmux send-keys -t 2 C-z
    tmux send-keys -t 3 C-z
fi

# Attach to the session now
tmux attach-session -t "$SESSION_NAME"
