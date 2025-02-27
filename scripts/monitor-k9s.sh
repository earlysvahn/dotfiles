#!/bin/zsh
SESSION_NAME="monitor-k9s"

if [[ -z "$GCP_DEV_CONTEXT" || -z "$GCP_TEST_CONTEXT" || -z "$GCP_STAGE_CONTEXT" || -z "$GCP_PROD_CONTEXT" ]]; then
    echo "Error: One or more GCP context variables are not set!"
    exit 1
fi

echo "Loading k9s...🐶"

tmux has-session -t "$SESSION_NAME" 2>/dev/null

if [[ $? != 0 ]]; then
    tmux new-session -d -s "$SESSION_NAME"

		tmux source-file "$HOME/dotfiles/config/tmux/.tmux.conf"

    tmux split-window -h

    tmux select-pane -t 0
    tmux split-window -v
    tmux select-pane -t 2
    tmux split-window -v

    tmux send-keys -t 0 "k9s --context=$GCP_PROD_CONTEXT" C-m
		tmux send-keys -t 1 "k9s --context=$GCP_TEST_CONTEXT" C-m
    tmux send-keys -t 2 "k9s --context=$GCP_STAGE_CONTEXT" C-m
    tmux send-keys -t 3 "k9s --context=$GCP_DEV_CONTEXT" C-m

    sleep 5

    tmux send-keys -t 0 C-z
    tmux send-keys -t 1 C-z
    tmux send-keys -t 2 C-z
    tmux send-keys -t 3 C-z
fi

tmux select-pane -t 0

tmux attach-session -t "$SESSION_NAME"
