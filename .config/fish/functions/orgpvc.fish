#!/usr/local/bin/fish

# use: cd /report && orgpvc report
function orgpvc
    echo "watching " $argv[1].org
    while inotifywait -e close_write $argv[1].org
        docker create -ti --rm --name cont janmasrovira/emacs-org:27.0
        docker start cont
        docker cp . cont:/home/
        set cmd "export EMACSLOADPATH=\$(cat /root/load-path) && cd /home/ && emacs $argv[1].org -batch -l ~/init.el -f org-latex-export-to-latex"
        echo $cmd
        docker exec cont sh -c $cmd
        docker cp cont:/home/$argv[1].tex .
        docker kill cont
    end
end
