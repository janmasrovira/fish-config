# use: get-tidal https://tidal.com/album/198596141
# downloads the album from tidal and copies it into the local beets library
function get-tidal --argument-names album
    set path ~/Downloads/get-tidal
    tidal-dl-ng dl "$album"
    beet import $path
    echo "updating mpc library... (safe to interrupt)"
    mpc update --wait
end
