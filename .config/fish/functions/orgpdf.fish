#!/usr/local/bin/fish

# it splits horizontally the current tmux pane into 2 panes.
# the top pane runs orgpvc and the bottom pane runs latexmk.

# use: cd /report && orgpdf report
function orgpdf
    set cmd "latexmk -pvc $argv[1]"
    set newpane (tmux split-window -v -P -F "#{pane_id}")
    sleep 0.1 # needed so fish has time to start in the new pane.
    tmux send-keys -t $newpane $cmd C-m
    orgpvc $argv[1]
end
