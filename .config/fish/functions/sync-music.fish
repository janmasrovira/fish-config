# Sync Bee's music library to Android devices over Termux SSH.

function __sync_music_usage
    echo 'usage: sync-music [-h|--help]

Sync the music library on Bee to 13t and/or tab-s9. One or both targets
are picked interactively with fzf. By default, rsync is first run with
--dry-run; after reviewing its output, you can approve the real sync.

The selected devices must have sshd and rsync available in Termux.'
end

# Match record-screen's fzf controls: start in j/k navigation mode, use
# Space for selection, and let Tab toggle between navigation and filtering.
function __sync_music_navargs
    set -l label $argv[1]
    set -l keys (string join ',' $argv[2..])
    set -l toggle "tab:transform:case \"\$FZF_PROMPT\" in *filter*) echo \"disable-search+rebind($keys)+clear-query+change-prompt($label nav> )\";; *) echo \"enable-search+unbind($keys)+change-prompt($label filter> )\";; esac"
    set -l args --reverse --disabled --prompt "$label nav> " \
        --bind 'j:down' --bind 'k:up' --bind $toggle --bind 'space:toggle'
    printf '%s\n' $args
end

function __sync_music_destination --argument-names target
    switch $target
        case 13t
            echo 'jan@13t:/storage/emulated/0/Music/'
        case tab-s9
            echo 'jan@tab-s9:/storage/6634-3264/Music/'
        case '*'
            return 1
    end
end

function __sync_music_bee_ssh_args
    printf '%s\n' -F /dev/null -o BatchMode=yes -o ConnectTimeout=8
end

function __sync_music_device_ssh_args
    printf '%s\n' \
        -p 8022 \
        -o BatchMode=yes \
        -o ConnectTimeout=8 \
        -o ServerAliveInterval=2 \
        -o ServerAliveCountMax=3
end

function __sync_music_check_with_spinner --argument-names target
    set -l frames ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏
    set -l frame_index 1
    set -l ticks 0
    set -l minimum_ticks 5
    set -l interactive no
    isatty stdout; and set interactive yes

    set -l progress_message "Testing music sync on $target"
    set -l success_message "music sync ready on $target"
    set -l failure_message "music sync unavailable on $target"
    set -l probe_command
    if test "$target" = bee
        set progress_message 'Connecting to Bee'
        set success_message 'Connected to Bee'
        set failure_message 'Cannot connect to Bee'
    else
        set -l destination (__sync_music_destination $target)
        or return 1
        set -l probe_destination (string join '' $destination '.sync-music-probe.txt')
        # A one-file dry run checks SSH, remote rsync, and the real destination
        # without scanning the music library or writing to the device.
        set -l device_probe_ssh (string join -- ' ' \
            (string escape -- ssh (__sync_music_device_ssh_args)))
        set -l device_probe_argv rsync --dry-run --timeout=8 \
            -e $device_probe_ssh /home/jan/copy-music-to-phone.txt $probe_destination
        set probe_command (string join -- ' ' (string escape -- $device_probe_argv))
    end

    # Draw before launching the background job so process startup is covered.
    if test "$interactive" = yes
        printf '\r%s %s...' $frames[$frame_index] $progress_message
    else
        echo "$progress_message..."
    end

    set -l probe_argv ssh (__sync_music_bee_ssh_args) bee
    if test "$target" = bee
        set -a probe_argv true
    else
        set -a probe_argv $probe_command
    end

    # Fish's `wait` does not preserve a background job's exit status. Have a
    # small external wrapper record it before exiting, then animate until the
    # status file is populated.
    set -l status_dir /tmp
    if set -q XDG_RUNTIME_DIR; and test -d "$XDG_RUNTIME_DIR"; and test -w "$XDG_RUNTIME_DIR"
        set status_dir $XDG_RUNTIME_DIR
    end
    set -l status_file (mktemp -p $status_dir sync-music-status.XXXXXX)
    or return 1
    command env SYNC_MUSIC_STATUS_FILE=$status_file sh -c \
        '"$@" >/dev/null 2>&1; rc=$?; printf "%s\n" "$rc" > "$SYNC_MUSIC_STATUS_FILE"' \
        sh $probe_argv &
    set -l probe_pid $last_pid

    if test "$interactive" = yes
        while true
            if test -s $status_file; and test $ticks -ge $minimum_ticks
                break
            end
            # Avoid spinning forever if the status-recording wrapper itself
            # exits unexpectedly before writing its result.
            if not command kill -0 $probe_pid 2>/dev/null; and not test -s $status_file
                break
            end

            command sleep 0.1
            set ticks (math $ticks + 1)
            set frame_index (math $frame_index % (count $frames) + 1)
            printf '\r%s %s...' $frames[$frame_index] $progress_message
        end
    end

    wait $probe_pid >/dev/null 2>&1
    set -l probe_status 1
    set -l recorded_status
    if read -l recorded_status <$status_file
        string match -qr '^\d+$' -- $recorded_status; and set probe_status $recorded_status
    end
    command rm -f -- $status_file
    if test "$interactive" = yes
        if test $probe_status -eq 0
            printf '\r\e[K\e[32m✓\e[0m %s\n' $success_message
        else
            printf '\r\e[K\e[31m✗\e[0m %s\n' $failure_message
        end
    end
    return $probe_status
end

function __sync_music_on_bee --argument-names dry_run
    set -l targets $argv[2..]
    set -l failed 0

    for target in $targets
        set -l destination (__sync_music_destination $target)
        or begin
            echo "sync-music: unknown target: $target" >&2
            return 1
        end

        set -l device_ssh_args (__sync_music_device_ssh_args)
        set -l device_ssh (string join -- ' ' (string escape -- ssh $device_ssh_args))
        set -l rsync_argv time rsync -rhvP --size-only \
            -e $device_ssh \
            /mnt/big-storage/music/ $destination \
            --stats --itemize-changes --delete
        if test "$dry_run" = yes
            set -a rsync_argv --dry-run
        end

        echo
        if test "$dry_run" = yes
            if isatty stdout
                printf '=== %s: \e[1;33mDRY RUN\e[0m ===\n' $target
            else
                echo "=== $target: DRY RUN ==="
            end
        else
            echo "=== $target: syncing ==="
        end

        set -l remote_command (string join -- ' ' (string escape -- $rsync_argv))
        if not command ssh (__sync_music_bee_ssh_args) bee $remote_command
            echo "sync-music: rsync failed for $target" >&2
            set failed 1
        end
    end

    return $failed
end

function sync-music --description 'Sync music from Bee to an Android device'
    argparse h/help -- $argv
    or begin
        __sync_music_usage >&2
        return 2
    end

    if set -q _flag_help
        __sync_music_usage
        return 0
    end

    if test (count $argv) -ne 0
        __sync_music_usage >&2
        return 2
    end

    for cmd in fzf ssh mktemp
        if not command -q $cmd
            echo "sync-music: '$cmd' not found in PATH" >&2
            return 1
        end
    end

    # Check Bee first because that is where the device probes and rsync run.
    __sync_music_check_with_spinner bee
    or begin
        echo 'sync-music: cannot connect to Bee' >&2
        return 1
    end

    set -l green (printf '\e[32m')
    set -l red (printf '\e[31m')
    set -l reset (printf '\e[0m')
    set -l rows
    for target in 13t tab-s9
        set -l availability unavailable
        set -l color $red
        if __sync_music_check_with_spinner $target
            set availability available
            set color $green
        end
        set -a rows (printf '%s\t%s● sync %s%s' $target $color $availability $reset)
    end

    set -l fzf_args --multi --ansi --delimiter \t --with-nth 1,2 --height 40% \
        --header 'space: select · j/k: move · Tab: filter/nav · Enter: confirm · Esc: cancel' \
        (__sync_music_navargs target j k space)
    set -l picked (printf '%s\n' $rows | fzf $fzf_args)
    or begin
        echo 'cancelled.' >&2
        return 130
    end

    set -l targets
    for row in $picked
        set -a targets (string split \t -- $row)[1]
    end

    while true
        set -l unavailable
        for target in $targets
            if not __sync_music_check_with_spinner $target
                set -a unavailable $target
            end
        end

        if test (count $unavailable) -eq 0
            break
        end

        echo
        echo 'Music sync is unavailable for:'
        printf '  %s\n' $unavailable
        echo 'Check Termux sshd, rsync, network access, and storage permissions.'
        read -l -P 'Fix the issue, then press Enter to retry (q to quit): ' answer
        or begin
            echo 'cancelled.' >&2
            return 130
        end
        if string match -qr '^[qQ]$' -- $answer
            echo 'cancelled.' >&2
            return 130
        end
    end

    echo
    set -l dry_prompt
    if isatty stdout
        set dry_prompt (printf 'Run rsync in \e[1;33mDRY-RUN\e[0m mode first? [Y/n] ')
    else
        set dry_prompt 'Run rsync in DRY-RUN mode first? [Y/n] '
    end
    read -l -P "$dry_prompt" dry_answer
    or begin
        echo 'cancelled.' >&2
        return 130
    end
    if string match -qr '^[nN]$' -- $dry_answer
        __sync_music_on_bee no $targets
        return $status
    end

    __sync_music_on_bee yes $targets
    or begin
        echo 'sync-music: dry run failed; real sync was not started' >&2
        return 1
    end

    echo
    read -l -P 'Dry run complete. Run the real sync now? [y/N] ' sync_answer
    or begin
        echo 'real sync skipped.'
        return 0
    end
    if not string match -qr '^[yY]$' -- $sync_answer
        echo 'real sync skipped.'
        return 0
    end

    __sync_music_on_bee no $targets
end
