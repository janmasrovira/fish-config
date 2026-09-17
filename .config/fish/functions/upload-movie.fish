function upload-movie -d "Upload a video to Jellyfin's movies directory on bee"
    if test (count $argv) -ne 1
        echo 'Usage: upload-movie <video-file>' >&2
        return 2
    end

    if contains -- "$argv[1]" -h --help
        echo 'Usage: upload-movie <video-file>'
        echo 'Uploads to bee:/mnt/big-storage/movies/ using rsync.'
        return 0
    end

    if not test -f "$argv[1]"; or not test -r "$argv[1]"
        echo "upload-movie: not a readable file: $argv[1]" >&2
        return 2
    end

    if not command -q rsync
        echo "upload-movie: 'rsync' not found in PATH" >&2
        return 1
    end

    set -l video (path resolve -- "$argv[1]"); or return 1

    command rsync -thv --progress --partial-dir=.rsync-partial -- \
        "$video" bee:/mnt/big-storage/movies/
end
