#!/usr/local/bin/fish

# use: cd /report && orgpvc report
function orgpvc --argument-names target
    orgpvc-generic latex $target
end
