#!/usr/local/bin/fish

# use: cd /report && orgpvc report
function orgpvc
    echo "watching " $argv[1].org
    while inotifywait -e close_write $argv[1].org
        docker create -ti --rm --name orgpvc janmasrovira/emacs-org:27.1
        docker start orgpvc
        docker cp . orgpvc:/home/
        set cmd "export EMACSLOADPATH=\$(cat /root/load-path) && cd /home/ && emacs $argv[1].org -batch -l ~/init.el -f load-init-block -f org-latex-export-to-latex"
        echo $cmd
        docker exec orgpvc sh -c $cmd
        docker cp orgpvc:/home/$argv[1].tex .
        docker kill orgpvc
    end
end
