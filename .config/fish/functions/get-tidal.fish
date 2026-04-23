function get-tidal -d "Download Tidal Album via tiddl and import into beets"
    if test (count $argv) -eq 0
        echo "usage: get-tidal <tidal-url>" >&2
        return 2
    end
    set -l album $argv[1]

    if not command -q tiddl
        echo "get-tidal: 'tiddl' not found in PATH" >&2
        return 1
    end
    if not command -q beet
        echo "get-tidal: 'beet' not found in PATH" >&2
        return 1
    end

    if not mountpoint -q ~/music-beets
        echo "get-tidal: ~/music-beets is not mounted" >&2
        echo "  try: sshfs bee:/mnt/big-storage/music ~/music-beets" >&2
        return 1
    end

    set -l tmpdir (mktemp -d); or return 1
    tiddl download --path "$tmpdir" url "$album"; or begin
        rm -rf "$tmpdir"
        return 1
    end
    beet import "$tmpdir"
    set -l rc $status
    rm -rf "$tmpdir"
    return $rc
end
