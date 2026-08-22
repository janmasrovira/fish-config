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
    tiddl download --path "$tmpdir" --dolby-atmos none url "$album"; or begin
        rm -rf "$tmpdir"
        return 1
    end

    # Detect 24-bit/96kHz FLACs and downsample to 16-bit/44.1kHz in place,
    # preserving cover art, attached pictures, chapters, and tags.
    set -l hires
    for f in (find "$tmpdir" -type f -iname '*.flac')
        set -l info (ffprobe -v error -select_streams a:0 \
            -show_entries stream=sample_rate,bits_per_raw_sample \
            -of default=nw=1:nk=1 "$f")
        if test (count $info) -ge 2; and test "$info[1]" = 96000; and test "$info[2]" = 24
            set -a hires $f
        end
    end

    if test (count $hires) -gt 0
        set -l JOBS (math "min("(count $hires)", "(nproc)")")
        echo "Downsampling "(count $hires)" 24-bit/96kHz FLAC(s) → 16-bit/44.1kHz with $JOBS job(s)"
        printf '%s\n' $hires | parallel --will-cite -j $JOBS --halt soon,fail=1 --bar \
            'ffmpeg -hide_banner -loglevel error -nostdin -y \
                -i {} \
                -map 0 -c copy \
                -c:a flac -ar 44100 -sample_fmt s16 \
                -af aresample=resampler=soxr:precision=28:dither_method=shibata \
                {}.cd.flac && mv -f {}.cd.flac {}'; or begin
            echo "get-tidal: downsample failed" >&2
            rm -rf "$tmpdir"
            return 1
        end
    end

    beet import "$tmpdir"
    set -l rc $status
    rm -rf "$tmpdir"
    return $rc
end
