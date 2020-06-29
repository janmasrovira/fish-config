#!/usr/local/bin/fish

# it splits horizontally the current tmux pane into 2 panes.
# the top pane runs orgpvc and the bottom pane runs latexmk.

# use: cd /report && orgtex report
function orgtex
    set cmd "latexmk -pvc $argv[1]"
    set newpane (tmux split-window -v -P -F "#{pane_id}")
    tmux send-keys -t $newpane $cmd C-m
    orgpvc $argv[1]
end
