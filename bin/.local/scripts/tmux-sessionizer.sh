#!/usr/bin/env bash

switch_to() {
    if [[ -z $TMUX ]]; then
        tmux attach-session -t $1
    else
        tmux switch-client -t $1
    fi
}

has_session() {
    tmux list-sessions | grep -q "^$1:"
}

hydrate() {
    # Target the shell window (2) so the source command doesn't land in nvim (window 1).
    if [ -f $2/.tmux-sessionizer ]; then
        tmux send-keys -t $1:2 "source $2/.tmux-sessionizer" c-M
    elif [ -f $HOME/.tmux-sessionizer ]; then
        tmux send-keys -t $1:2 "source $HOME/.tmux-sessionizer" c-M
    fi
}

setup_windows() {
    # $1 = session name, $2 = directory
    # Window 1: nvim in the directory. Window 2: a shell.
    tmux new-window -t "$1" -c "$2"
    tmux send-keys -t "$1:1" "nvim ." c-M
    tmux select-window -t "$1:1"
}

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/ ~/personal ~/work ~/.dotfiles -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -ds $selected_name -c $selected -e "TMUX_SESSION_HOME=$selected"
    setup_windows $selected_name $selected
    hydrate $selected_name $selected
    tmux attach-session -t $selected_name
    exit 0
fi

if ! has_session $selected_name; then
    tmux new-session -ds $selected_name -c $selected -e "TMUX_SESSION_HOME=$selected"
    setup_windows $selected_name $selected
    # Next line are for session home var
    hydrate $selected_name $selected
fi

switch_to $selected_name
