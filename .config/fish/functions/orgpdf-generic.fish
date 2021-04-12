#!/usr/local/bin/fish

# it splits horizontally the current tmux pane into 2 panes.
# the top pane runs orgpvc-generic and the bottom pane runs latexmk.

# use: cd /report && orgpdf [latex | beamer] report
function orgpdf-generic --argument-names backend target
    set cmd "latexmk -pvc $target"
    set newpane (tmux split-window -v -P -F "#{pane_id}")
    sleep 0.1 # needed so fish has time to start in the new pane.
    tmux send-keys -t $newpane $cmd C-m
    orgpvc-generic $backend $target
end
