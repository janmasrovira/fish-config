abbr -a ll "eza -lah --icons auto"
abbr -a ls "eza --icons auto"
abbr -a la "eza -a --icons auto"
abbr -a diff "delta"
abbr -a find "fd"
abbr -a r "cd (command git rev-parse --show-toplevel)"
abbr -a cp "rsync -avhP"
abbr -a ec "emacsclient -c"
abbr -a es "emacs --daemon"
abbr -a mp "ncmpcpp"
abbr -a cap "setxkbmap -option \"ctrl:swapcaps\""
abbr -a cat "bat"
abbr -a wcpe "mpv http://audio-ogg.ibiblio.org:8000/wcpe.ogg"
abbr -a findpi "sudo nmap -sP 192.168.1.0/24 | rg -B 2 Raspberry"
abbr -a findpi "sudo nmap -sP 192.168.1.0/24 | rg -B 2 Wibrain"

abbr -a bumusic "time rsync -ahvP /home/jan/music-pi/ microsd/music/ --itemize-changes --no-perms --no-times --no-owner --no-group --size-only --delete --dry-run"
abbr -a watch "watch -n 0.5"

abbr -a dirsize "du -hs"

abbr -a smake "make -C (command git rev-parse --show-toplevel)"

abbr -a ctrl "xmodmap ~/.xmonad swap_control_caps"

abbr -a top "btop"

abbr -a xclib "xclip -selection clipboard"

abbr -a concatflac "shntool join -n -o flac *.flac"

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

# java jdk
set --export JAVA_HOME /usr/lib/jvm/java-15-adoptopenjdk

# fixes issues (such as blank window) with java applications (such as REW)
set --export _JAVA_AWT_WM_NONREPARENTING 1

#stack bin export
set PATH ~/.local/bin $PATH

#cabal bin
set PATH ~/.cabal/bin $PATH

# juvix hack
set --export ORMOLU ~/.local/bin/ormolu

# global stack ghc bin
# set PATH ~/.stack/programs/x86_64-linux/ghc-tinfo6-9.2.4/bin $PATH

# ghcup
set PATH ~/.ghcup/bin $PATH

# set PATH $PATH ~/dotfiles/doom/.emacs.d/bin
set PATH $PATH ~/.config/emacs/bin

# rust
# set --export RUST_SRC_PATH "$(rustc --print sysroot)/lib/rustlib/src/rust/src"
set PATH $PATH ~/.cargo/bin

# texlive 2023
set PATH $PATH /usr/local/texlive/2023/bin/x86_64-linux

# wasi
set --export WASI_SYSROOT_PATH ~/programs/wasi-sysroot

# JP input
# When @im=fcitx I cannot insert ^ and ` in emacs
# set --export XMODIFIERS @im=fcitx
# set --export GTK_IM_MODULE fcitx
# set --export QT_IM_MODULE fcitx

# needed to make android studio work on xmonad
# https://wiki.haskell.org/Xmonad/Frequently_asked_questions#Problems_with_Java_applications.2C_Applet_java_console
# set --export _JAVA_AWT_WM_NONREPARENTING 1

# xdg config home
set --export XDG_CONFIG_HOME $HOME/.config

# google-cloud-sdk binaries (gsutil, gcloud...)
set PATH ~/programs/google-cloud-sdk/bin $PATH

set --export VISUAL emacsclient -c -a gedit
set EDITOR emacsclient

set --export LEDGER_FILE ~/projects/balances/balances.journal

jan_key_bindings

if type -q zoxide
    zoxide init fish | source
end

if type -q starship
    starship init fish | source
end

if type -q atuin
    atuin init fish --disable-up-arrow | source
end
