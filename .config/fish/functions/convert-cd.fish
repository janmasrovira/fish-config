#!/usr/bin/env fish
# Resample 96k/24-bit FLACs in this folder to 44.1k/16-bit, preserving
# all non-audio streams (cover video, attached pictures, chapters, tags).
# Audio: soxr resampler (very-high precision) + Shibata noise-shaped dither.

set -l SRCDIR (status dirname)
set -l OUTDIR "$SRCDIR/cd_quality"
mkdir -p $OUTDIR

# Cap at min(file_count, nproc) so we don't oversubscribe.
set -l files $SRCDIR/*.flac
if test (count $files) -eq 0
    echo "No .flac files in $SRCDIR" >&2
    exit 1
end
set -l JOBS (math "min("(count $files)", "(nproc)")")

echo "Converting "(count $files)" file(s) with $JOBS parallel job(s) → $OUTDIR"

printf '%s\n' $files | parallel --will-cite -j $JOBS --bar \
    ffmpeg -hide_banner -loglevel error -nostdin -y \
        -i {} \
        -map 0 -c copy \
        -c:a flac -ar 44100 -sample_fmt s16 \
        -af aresample=resampler=soxr:precision=28:dither_method=shibata \
        $OUTDIR/{/}

echo "Done."
