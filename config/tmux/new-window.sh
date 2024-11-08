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
