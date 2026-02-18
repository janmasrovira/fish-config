# use: get-tidal https://tidal.com/album/198596141
# downloads the album from tidal and copies it into the local beets library
function get-tidal --argument-names album
    set path ~/Downloads/tiddl
    rm -rf $path
    mkdir -p $path
    tiddl download url "$album"
    beet import $path
end
