#!/bin/bash

SESSION="dev"

tmux new-session -d -s $SESSION

# Capture pane IDs as we split
P1=$(tmux display-message -p "#{pane_id}")
P2=$(tmux split-window -h -PF "#{pane_id}")
P3=$(tmux split-window -v -t $P1 -PF "#{pane_id}")
P4=$(tmux split-window -v -t $P2 -PF "#{pane_id}")

# Run commands in first three panes
tmux send-keys -t $P1 "roslaunch dv_ros_capture capture.launch" Enter
tmux send-keys -t $P2 "watch rostopic list" Enter
tmux send-keys -t $P3 "sleep 1" Enter
tmux send-keys -t $P3 "roslaunch vrpn_client_ros sample.launch" Enter

tmux send-keys -t $P4 "cd ~/event_ws" Enter
# Focus the fourth pane (cursor ready)
tmux select-pane -t $P4

tmux attach-session -t $SESSION
