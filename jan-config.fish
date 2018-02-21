abbr -a ll "ls -alF"
abbr -a la "ls -A"
abbr -a l "ls -CF"
abbr -a ls "ls --color=auto"

abbr -a enw "emacsclient -nw"
abbr -a e "emacsclient -c"
abbr -a ec "emacsclient -c"
abbr -a es "emacs --daemon"
abbr -a esc "emacs --daemon and emacsclient -c"
abbr -a ipython_notebook "ipython3 notebook --pylab inline"
abbr -a pdf "zathura"

# note that the trailing / is important!
abbr -a bumusic "time rsync -a -v --delete --progress /media/jan/LocalDisk/Music/ /media/jan/Disc/Music/"
abbr -a bumovies "time rsync -a -v --progress /media/jan/Dades/Jan/Movies/ /media/jan/Disc/Movies/"
abbr -a watch "watch -n 0.5"

abbr -a dirsize "du -hs"

abbr -a top "htop" #htop = improved top

abbr -a xclib "xclip -selection clipboard" # can copy things to emacs... yay

abbr -a chrome "google-chrome"

abbr -a concatflac "shntool join -n -o flac *.flac"

abbr -a mountsteam "sudo mount /dev/sda5 /home/jan/Mount/ -o umask=000"

abbr -a getaudio "youtube-dl --extract-audio --audio-quality 9" #download audio
# from a youtube video usage example: getaudio
# https://www.youtube.com/watch?v=f6CrzLXUHx4.
#
# Since google music does not support m4a, you should convert the downloaded
# file afterwards to a suitable format (eg ogg): ffmpeg -i file.m4a -f ogg
# file.ogg. Note that youtube-dl also offers an options for audio conversion,
# but the size of the converted file is much larger than the original, which
# does not make any sense.

abbr -a gitzip "git archive HEAD --format=zip > repo.zip"

abbr -a texclean "rm -rf auto/ *.log *.toc *.aux"

#own python modules
set --export PYTHONPATH $HOME/projects $PYTHONPATH

# use '.' in decimal numbers
set --export LC_NUMERIC "en_US.UTF-8"

# java jdk
set --export JAVA_HOME /usr/local/lib/jdk1.8.0_92

# java 8 jdk bin
set PATH $PATH /usr/local/lib/jdk1.8.0_92/bin

#stack bin export
set PATH $HOME/.local/bin $PATH

# global stack ghc bin
set PATH /home/jan/.stack/programs/x86_64-linux/ghc-8.2.2/bin $PATH

# HOL path
set HOLDIR $HOLDIR ~/programs/HOL
set PATH $HOLDIR/bin $PATH

# sdkman
set PATH $PATH ~/.sdkman/candidates/kotlin/current/bin

# rust
# set --export RUST_SRC_PATH "$(rustc --print sysroot)/lib/rustlib/src/rust/src"

# needed to make android studio work on xmonad
# https://wiki.haskell.org/Xmonad/Frequently_asked_questions#Problems_with_Java_applications.2C_Applet_java_console
set --export _JAVA_AWT_WM_NONREPARENTING 1

# xdg config home
set --export XDG_CONFIG_HOME $HOME/.config

# google-cloud-sdk binaries (gsutil, gcloud...)
set PATH $HOME/programs/google-cloud-sdk/bin $PATH

set VISUAL emacsclient -c -a gedit
set EDITOR emacsclient

# OCAML
set PATH $HOME/.opam/4.03.0+flambda/bin $PATH

set -g Z_SCRIPT_PATH $HOME/.zsh/z.sh
#opl shared libraries
# set LD_LIBRARY_PATH $LD_LIBRARY_PATH $HOME/Programs/cplex-studio126/opl/bin/x86-64_linux

#cplex libraries
# set CPLUS_INCLUDE_PATH $CPLUS_INCLUDE_PATH $HOME/Programs/CPLEX_Enterprise_Server126/CPLEX_Studio/cplex/include/
# set LD_LIBRARY_PATH $LD_LIBRARY_PATH $HOME/Programs/CPLEX_Enterprise_Server126/CPLEX_Studio/cplex/lib/x86-64_linux/static_pic
# set LIBRARY_PATH $LIBRARY_PATH $HOME/Programs/CPLEX_Enterprise_Server126/CPLEX_Studio/cplex/lib/x86-64_linux/static_pic

# #concert libraries (cplex c++ api)
# set CPLUS_INCLUDE_PATH $CPLUS_INCLUDE_PATH $HOME/Programs/CPLEX_Enterprise_Server126/CPLEX_Studio/concert/include
# set LD_LIBRARY_PATH $LD_LIBRARY_PATH $HOME/Programs/CPLEX_Enterprise_Server126/CPLEX_Studio/concert/lib/x86-64_linux/static_pic
# set LIBRARY_PATH $LIBRARY_PATH $HOME/Programs/CPLEX_Enterprise_Server126/CPLEX_Studio/concert/lib/x86-64_linux/static_pic

# advanced functional programming lab3 reactive banana
set --export LD_LIBRARY_PATH $LD_LIBRARY_PATH $HOME/projects/reactive-spreadsheet/.stack-work/install/x86_64-linux/lts-6.30/7.10.3/lib/x86_64-linux-ghc-7.10.3/wxc-0.92.2.0-Be0BIRCq3e9CuTZLB6Mhx8
