abbr -a ll "exa -lah --icons"
abbr -a la "exa -a --icons"
abbr -a ls "exa --icons"
abbr -a bs "br -p"
abbr -a bd "br -pf"
abbr -a enw "emacsclient -nw"
abbr -a e "emacsclient -c"
abbr -a ec "emacsclient -c"
abbr -a es "emacs --daemon"
abbr -a esc "emacs --daemon and emacsclient -c"
abbr -a pdf "zathura"
abbr -a mp "ncmpcpp"
abbr -a cap "setxkbmap -option \"ctrl:swapcaps\""
abbr -a cat "bat"
abbr -a wcpe "mpv http://audio-ogg.ibiblio.org:8000/wcpe.ogg"

# note that the trailing / is important!
abbr -a bumusic "time rsync -a -v --delete --progress /media/jan/LocalDisk/Music/ /media/jan/Disc/Music/"
abbr -a bumovies "time rsync -a -v --progress /media/jan/Dades/Jan/Movies/ /media/jan/Disc/Movies/"
abbr -a watch "watch -n 0.5"

abbr -a dirsize "du -hs"

abbr -a ctrl "xmodmap ~/.xmonad swap_control_caps"

abbr -a top "htop" #htop = improved top

abbr -a xclib "xclip -selection clipboard"

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

abbr -a texclean "rm -rf auto/ *.log *.toc *.aux *.fls *.bcf *.gls *.ist *.run.xml *.glg *.blg *.fdb_latexmk _minted* *.out *.pyg *.glo *.synctex.gz"

set --export TERM xterm-256color

#own python modules
set --export PYTHONPATH $HOME/projects $PYTHONPATH

# use '.' in decimal numbers
set --export LC_NUMERIC "en_US.UTF-8"

# java jdk
set --export JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

#stack bin export
set PATH ~/.local/bin $PATH

#cabal bin
set PATH ~/.cabal/bin $PATH

# global stack ghc bin
set PATH ~/.stack/programs/x86_64-linux/ghc-8.6.5/bin $PATH

# sdkman
set PATH $PATH ~/.sdkman/candidates/kotlin/current/bin

# emacs cask
set PATH $PATH ~/.cask/bin

# rust
# set --export RUST_SRC_PATH "$(rustc --print sysroot)/lib/rustlib/src/rust/src"
set PATH $PATH ~/.cargo/bin

# ocaml / opam
set PATH $PATH ~/.opam/4.10.0/bin

# texlive 2020
set PATH $PATH /usr/local/texlive/2020/bin/x86_64-linux

# needed to make android studio work on xmonad
# https://wiki.haskell.org/Xmonad/Frequently_asked_questions#Problems_with_Java_applications.2C_Applet_java_console
set --export _JAVA_AWT_WM_NONREPARENTING 1

# xdg config home
set --export XDG_CONFIG_HOME $HOME/.config

# google-cloud-sdk binaries (gsutil, gcloud...)
set PATH ~/programs/google-cloud-sdk/bin $PATH

set VISUAL emacsclient -c -a gedit
set EDITOR emacsclient

#opl shared libraries
# set LD_LIBRARY_PATH $LD_LIBRARY_PATH $HOME/Programs/cplex-studio126/opl/bin/x86-64_linux

# libfuse, for sshfs
set --export LD_LIBRARY_PATH $LD_LIBRARY_PATH /usr/local/lib

set --export LEDGER_FILE ~/projects/balances/balances.hledger

# starship init
starship init fish | source
