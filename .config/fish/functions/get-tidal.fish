function get-tidal -d "Choose a Tidal audio format, download, and import into beets"
    if test (count $argv) -ne 1
        echo "usage: get-tidal <tidal-url>" >&2
        return 2
    end
    set -l album $argv[1]

    set -l downloader (command -s tidal-get)
    if test -z "$downloader"
        set downloader ~/local/bin/tidal-get
        if not test -x "$downloader"
            echo "get-tidal: 'tidal-get' not found in PATH or ~/local/bin" >&2
            return 1
        end
    end
    if not command -q beet
        echo "get-tidal: 'beet' not found in PATH" >&2
        return 1
    end

    if not mountpoint -q ~/music-beets
        echo "get-tidal: ~/music-beets is not mounted" >&2
        read -l -P 'Run sshfs bee:/mnt/big-storage/music ~/music-beets? [y/N] ' answer
        or return 1
        if not string match -qri '^y(es)?$' -- "$answer"
            return 1
        end

        if not command -q sshfs
            echo "get-tidal: 'sshfs' not found in PATH" >&2
            return 1
        end
        sshfs bee:/mnt/big-storage/music ~/music-beets
        or begin
            echo "get-tidal: sshfs mount failed" >&2
            return 1
        end
        if not mountpoint -q ~/music-beets
            echo "get-tidal: ~/music-beets is still not mounted" >&2
            return 1
        end
    end

    set -l tmpdir (mktemp -d); or return 1
    "$downloader" "$album" --output "$tmpdir"
    set -l rc $status
    if test $rc -ne 0
        rm -rf "$tmpdir"
        return $rc
    end

    beet import "$tmpdir"
    set rc $status
    rm -rf "$tmpdir"
    return $rc
end
