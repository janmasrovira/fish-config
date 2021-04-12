#!/usr/local/bin/fish

# it splits horizontally the current tmux pane into 2 panes.
# the top pane runs orgpvc and the bottom pane runs latexmk.

# use: cd /report && orgpdf report
function orgpdf
    orgpvc-generic latex $target
end
