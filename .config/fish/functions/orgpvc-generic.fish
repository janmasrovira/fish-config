# use: cd /report && orgpvc-generic [latex | beamer] report
function orgpvc-generic --argument-names backend target
    echo "watching " $target.org
    while inotifywait -e close_write $target.org
        docker create -ti --rm --name orgpvc -v (pwd):/home/work janmasrovira/emacs-org:27.2
        docker start orgpvc
        set cmd "export EMACSLOADPATH=\$(cat /root/load-path) && cd /home/work && emacs $target.org -batch -l ~/init.el -f load-init-block -f org-$backend-export-to-latex"
        echo $cmd
        docker exec orgpvc sh -c $cmd
        docker kill orgpvc
    end
end
