# use: orghtml orgfile (without extension)
function orghtml
    echo "watching " $argv[1].org
    while inotifywait -e close_write $argv[1].org
        set cmd "time emacs $argv[1].org -batch -f org-html-export-to-html"
        echo $cmd
        eval $cmd
    end
end
