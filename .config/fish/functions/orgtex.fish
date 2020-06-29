#!/usr/local/bin/fish

# it splits horizontally the current tmux pane into 2 panes.
# the top pane runs orgpvc and the bottom pane runs latexmk.

# use: cd /report && orgtex report
function orgtex
    set cmd "latexmk -pvc $argv[1]"
    tmux split-window -v
    tmux send-keys -t bottom $cmd C-m
    orgpvc $argv[1]
end
