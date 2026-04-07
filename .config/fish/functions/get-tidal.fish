# use: get-tidal https://tidal.com/album/198596141
# downloads the album from tidal and copies it into the local beets library
function get-tidal --argument-names album
    set path (mktemp -d); or return 1
    trap "rm -rf $path" EXIT
    tiddl download  --path $path url "$album"
    beet import $path
end
