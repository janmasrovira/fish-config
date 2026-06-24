# use: cd /report && orgpvc-generic [latex | beamer] report
function orgpvc-generic --argument-names backend target
    echo "watching " $target.org
    set dockerversion "2025-08-01"
    echo "using docker emacs-org:$dockerversion"
    # watch the dir, not the file, so atomic saves (rename) don't drop the watch
    inotifywait -q -m -e close_write -e moved_to --format '%f' (pwd) | while read -l changed
        test "$changed" = "$target.org"; or continue
        docker create -ti --rm --name orgpvc -v (pwd):/home/work janmasrovira/emacs-org:$dockerversion
        docker start orgpvc
        set cmd "export EMACSLOADPATH=\$(cat /root/load-path) && cd /home/work && emacs $target.org -batch -l ~/init.el -f load-init-block -f org-$backend-export-to-latex"
        echo $cmd
        docker exec orgpvc sh -c $cmd
        docker kill orgpvc
    end
end
