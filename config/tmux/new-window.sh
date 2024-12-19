#!/bin/bash

window_name="$1"
pane_path=$(tmux display-message -p "#{pane_current_path}")

case "$window_name" in
"git")
        tmux new-window -c "$pane_path" -n "$window_name" "lazygit"
        ;;
"air")
        tmux new-window -c "$pane_path" -n "$window_name" "air"
        ;;
"watch")
        tmux new-window -c "$pane_path" -n "$window_name" "gh run watch"
        ;;
"build")
        tmux new-window -c "$pane_path" -n "$window_name" "bash -c 'gh workflow run --ref $(git rev-parse --abbrev-ref HEAD) && sleep 2 && gh run watch'"
        ;;
"code")
        tmux new-window -c "$pane_path" -n "$window_name" "nvim"
        ;;
"db")
        tmux new-window -c "$pane_path" -n "$window_name" "nvim +DBUI"
        ;;
"dr")
        tmux new-window -c "$pane_path" -n "$window_name" "bash -l -c 'source ~/dotfiles/config/functions/dotnet_functions.sh && dotnet_run_fzf'"
        ;;
*)
        tmux new-window -c "$pane_path" -n "$window_name"
        ;;
esac
