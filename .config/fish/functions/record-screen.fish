# Common fzf flags for the interactive pickers: start in nav mode (search
# disabled) with j/k movement, and bind Tab to toggle between nav and
# text-filter mode. $argv[1] is the picker label (e.g. "monitor"); the
# remaining args are the keys to unbind/rebind across the toggle ("j" "k",
# plus "space" for the multi-select audio picker).
function __record_screen_navargs
    set -l label $argv[1]
    set -l keys (string join ',' $argv[2..])
    set -l toggle "tab:transform:case \"\$FZF_PROMPT\" in *filter*) echo \"disable-search+rebind($keys)+clear-query+change-prompt($label nav> )\";; *) echo \"enable-search+unbind($keys)+change-prompt($label filter> )\";; esac"
    set -l args --reverse --disabled --prompt "$label nav> " --bind 'j:down' --bind 'k:up' --bind $toggle
    contains space $argv[2..]; and set -a args --bind 'space:toggle'
    printf '%s\n' $args
end

function record-screen --description 'Record the screen with ffmpeg (interactive)'
    for cmd in ffmpeg fzf pactl xrandr
        if not type -q $cmd
            echo "record-screen: '$cmd' not found in PATH" >&2
            return 1
        end
    end
    if test -z "$DISPLAY"
        echo "DISPLAY is not set; this only supports X11" >&2
        return 1
    end

    # --- pick the monitor (fzf, single) ---
    # Collect connected outputs as "Xoffset\tname\tWxH+X+Y", sorted left to
    # right by X offset so we can tag each with its physical position.
    set -l rows
    for line in (xrandr --query | string match -r '^\S+ connected.*\d+x\d+\+\d+\+\d+.*')
        set -l name (string split -f1 ' ' $line)
        set -l geom (string match -r '\d+x\d+\+\d+\+\d+' $line)
        set -l xoff (string match -rg '^\d+x\d+\+(\d+)\+' -- $geom)
        set -a rows (printf '%s\t%s\t%s' $xoff $name $geom)
    end
    if test (count $rows) -eq 0
        echo "No connected monitors found" >&2
        return 1
    end
    set rows (printf '%s\n' $rows | sort -n)

    # Each line is "label\tWxH+X+Y"; fzf shows the label, we parse the geom.
    set -l n (count $rows)
    set -l monlines
    for i in (seq $n)
        set -l parts (string split \t -- $rows[$i])
        set -l name $parts[2]
        set -l geom $parts[3]
        set -l pos
        if test $n -ge 2
            if test $n -eq 2
                set pos (test $i -eq 1; and echo left; or echo right)
            else if test $n -eq 3
                set -l three left center right
                set pos $three[$i]
            else if test $i -eq 1
                set pos left
            else if test $i -eq $n
                set pos right
            else
                set pos "$i. from left"
            end
            set name "$name ($pos)"
        end
        set -a monlines (printf '%s\t%s' $name $geom)
    end
    set -l screen (xrandr --query | string match -rg 'current (\d+) x (\d+)')
    set -a monlines (printf 'All monitors\t%sx%s+0+0' $screen[1] $screen[2])
    # Sentinel row: draw a rectangle with slop and record just that region.
    set -a monlines (printf 'Select region (draw rectangle)…\t__REGION__')

    set -l pick (printf '%s\n' $monlines \
        | fzf --delimiter \t --with-nth 1 --height 40% \
            --header 'j/k: move · Tab: filter/nav · Enter: confirm' \
            (__record_screen_navargs monitor j k)); or return 1
    set -l g (string split -f2 \t -- $pick)

    # Region: query a rectangle interactively, then fall through to the same
    # geometry parsing as the monitor case.
    if test "$g" = __REGION__
        if not type -q slop
            echo "record-screen: 'slop' not found; install it to select a region" >&2
            return 1
        end
        set g (slop -f '%wx%h+%x+%y'); or return 1
        # x11grab + libx264 (yuv420p) need even dimensions; round W/H down.
        set -l rw (string match -rg '^(\d+)x' -- $g)
        set -l rh (string match -rg '^\d+x(\d+)\+' -- $g)
        set -l rest (string replace -r '^\d+x\d+' '' -- $g)
        set g (math "$rw - $rw % 2")x(math "$rh - $rh % 2")$rest
    end
    set -l size (string match -rg '^(\d+x\d+)' -- $g)
    set -l offset (string replace -r '^\d+x\d+\+' '' -- $g | string replace '+' ',')

    # --- frame rate (fixed; x11grab tops out around 30 at 1440p+) ---
    set -l fps 30

    # --- pick audio inputs (fzf, multi) ---
    # Every source PulseAudio/PipeWire knows about — the same set pavucontrol
    # shows: real inputs (mics, webcams) plus the .monitor of each output
    # (desktop/PC audio). The default mic and PC audio are highlighted and
    # pre-selected; Tab toggles, Enter confirms, Esc selects none. Multiple
    # inputs are mixed down to a single track.
    set -l defsink (pactl get-default-sink)".monitor"
    set -l defsrc (pactl get-default-source)
    # Build the list with the default PC audio and mic first (tagged in
    # brackets), then everything else, so the common picks are at the top.
    set -l deflines
    set -l otherlines
    for line in (pactl list sources | awk -F': ' '/^\tName: /{n=$2} /^\tDescription: /{print n"|"$2}')
        set -l name (string split -m1 '|' -- $line)[1]
        set -l desc (string split -m1 '|' -- $line)[2]
        if test "$name" = "$defsink"
            set -a deflines (printf '%s\t%s [default PC audio]' $name $desc)
        else if test "$name" = "$defsrc"
            set -a deflines (printf '%s\t%s [default mic]' $name $desc)
        else
            set -a otherlines (printf '%s\t%s' $name $desc)
        end
    end
    set -l srclines $deflines $otherlines

    # Pre-select the defaults, which now occupy the first rows.
    set -l preselect
    for i in (seq (count $deflines))
        set -a preselect "pos($i)+select"
    end

    set -l fzf_args --multi --ansi --delimiter \t --with-nth 2 --height 50% \
        --header 'space: select · j/k: move · Tab: filter/nav · Enter: confirm · Esc: none' \
        (__record_screen_navargs audio j k space)
    if test (count $preselect) -gt 0
        set -a fzf_args --bind 'load:'(string join '+' $preselect)'+first'
    end
    set -l picks (printf '%s\n' $srclines | fzf $fzf_args | string split -f1 \t)

    set -l ain
    for p in $picks
        set -a ain -f pulse -i $p
    end

    # --- assemble filter graph, stream maps, and encoders ---
    # Always H.264 (software libx264) + Opus. A keyframe every ~2s keeps
    # seeking responsive. Audio inputs are ffmpeg inputs 1..N (input 0 is
    # the x11grab video).
    set -l gop (math "round($fps * 2)")
    set -l venc -c:v libx264 -g $gop
    set -l vmap -map 0:v
    set -l graph

    set -l aenc
    set -l amap
    switch (count $picks)
        case 0
            set aenc -an
        case 1
            set aenc -c:a libopus -b:a 128k
            set amap -map 1:a
        case '*'
            set -l labels
            for i in (seq (count $picks))
                set -a labels "[$i:a]"
            end
            set -a graph (string join '' $labels)"amix=inputs="(count $picks)":duration=longest[a]"
            set aenc -c:a libopus -b:a 128k
            set amap -map '[a]'
    end

    set -l fc
    if test (count $graph) -gt 0
        set fc -filter_complex (string join ';' $graph)
    end

    # --- output file ---
    set -l default_out ~/Videos/recording-(date +%Y%m%d-%H%M%S).mkv
    read -l -P "Output file [$default_out]: " out
    test -z "$out"; and set out $default_out
    mkdir -p (dirname $out)

    echo
    echo "Recording $size at $fps fps -> $out"
    echo "Press q to stop (Ctrl-C may leave the file unfinalized)."
    echo

    ffmpeg \
        -f x11grab -framerate $fps -video_size $size -i $DISPLAY+$offset \
        $ain \
        $fc \
        $vmap $venc \
        $amap $aenc \
        $out
    or echo "ffmpeg exited with an error" >&2

    echo "Output: $out"
end
