#!/usr/bin/env bash

export TMUX_CONFIG="$HOME/dotfiles/tmux/.tmux.conf"
t() {
	command tmux -f $TMUX_CONFIG "$@"
}

if [[ $# -eq 1 ]]; then
	selected=$2
else
	selected=$(find $HOME/Development $HOME/private-dev $HOME/Development/dooris-repo/apps $HOME/.config $HOME/dotfiles -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
	exit 0
fi
selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
	t new-session -s $selected_name -c $selected -n '🧛 vim' \; \
		new-window -n '🌳 git' \; \
		send-keys -t $selected_name:'🌳 git' 'lazygit' C-m \; \
		select-window -t $selected_name:'🧛 vim' \; \
		send-keys -t $selected_name:'🧛 vim' 'nvim .' C-m
	exit 0
fi

if ! tmux has-session -t=$selected_name 2>/dev/null; then
	t new-session -ds $selected_name -c $selected -n '🧛 vim' \; \
		new-window -n '🌳 git' \; \
		send-keys -t $selected_name:'🌳 git' 'lazygit' C-m \; \
		select-window -t $selected_name:'🧛 vim' \; \
		send-keys -t $selected_name:'🧛 vim' 'nvim .' C-m
fi

if ! { [ -n "$TMUX" ]; }; then
	t attach-session -t $selected_name
else
	t switch-client -t $selected_name
fi
