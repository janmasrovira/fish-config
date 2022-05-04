abbr -a ll "exa -lah --icons"
abbr -a find "fd"
abbr -a la "exa -a --icons"
abbr -a ls "exa --icons"
abbr -a bs "br -p"
abbr -a bd "br -pf"
abbr -a cp "rsync -avhP"
abbr -a enw "emacsclient -nw"
abbr -a e "emacsclient -c"
abbr -a ec "emacsclient -c"
abbr -a es "emacs --daemon"
abbr -a esc "emacs --daemon and emacsclient -c"
abbr -a mp "ncmpcpp"
abbr -a cap "setxkbmap -option \"ctrl:swapcaps\""
abbr -a cat "bat"
abbr -a cloc "tokei"
abbr -a wcpe "mpv http://audio-ogg.ibiblio.org:8000/wcpe.ogg"
abbr -a findpi "sudo nmap -sP 192.168.1.0/24 | awk '/^Nmap/{ip=\$NF}/B8:27:EB/{print ip}'"
abbr -a doom "doom --doomdir ~/dotfiles/doom/.doom.d --localdir ~/dotfiles/doom/.emacs.d/.local"

# Add ~/coq/bin (my local dev branch of Coq) to the PATH
# This allows emacs to find it
set PATH ~/projects/fv/coq/_build/install/default/bin $PATH
# Tells make to automatically use dune in coq dev
set --export COQ_USE_DUNE true


# note that the trailing / is important!
abbr -a bumusic "time rsync -ahvP /run/media/jan/LocalDisk/Music/ pi/music/"
abbr -a bumusicdel "time rsync -ahvP --delete --exclude '*.nfo' /run/media/jan/LocalDisk/Music/ pi/music/"
abbr -a watch "watch -n 0.5"

abbr -a dirsize "du -hs"

abbr -a ctrl "xmodmap ~/.xmonad swap_control_caps"

abbr -a top "htop" #htop = improved top

abbr -a xclib "xclip -selection clipboard"

abbr -a chrome "google-chrome"

abbr -a concatflac "shntool join -n -o flac *.flac"

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

# use '.' in decimal numbers
set --export LC_NUMERIC "en_US.UTF-8"

# java jdk
set --export JAVA_HOME /usr/lib/jvm/java-15-adoptopenjdk

#stack bin export
set PATH ~/.local/bin $PATH

#cabal bin
set PATH ~/.cabal/bin $PATH

# global stack ghc bin
set PATH ~/.stack/programs/x86_64-linux/ghc-tinfo6-9.2.2/bin $PATH

set PATH $PATH ~/dotfiles/doom/.emacs.d/bin

# rust
# set --export RUST_SRC_PATH "$(rustc --print sysroot)/lib/rustlib/src/rust/src"
set PATH $PATH ~/.cargo/bin

# ocaml / opam
# set PATH $PATH ~/.opam/4.10.0/bin
if type -q opam
    eval (opam env)
end

# texlive 2022
set PATH $PATH /usr/local/texlive/2022/bin/x86_64-linux

# emscripten
set PATH $PATH /usr/lib/emscripten/

# needed to make android studio work on xmonad
# https://wiki.haskell.org/Xmonad/Frequently_asked_questions#Problems_with_Java_applications.2C_Applet_java_console
# set --export _JAVA_AWT_WM_NONREPARENTING 1

# xdg config home
set --export XDG_CONFIG_HOME $HOME/.config

# google-cloud-sdk binaries (gsutil, gcloud...)
set PATH ~/programs/google-cloud-sdk/bin $PATH

set VISUAL emacsclient -c -a gedit
set EDITOR emacsclient

set --export LEDGER_FILE ~/projects/balances/balances.hledger

jan_key_bindings

if type -q starship
    starship init fish | source
end
