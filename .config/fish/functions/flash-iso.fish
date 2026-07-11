# flash-iso [-a|--all] [-n|--dry-run] <image.iso>
# Write an ISO to a whole USB disk with dd. USB-only unless --all; --dry-run
# writes nothing. Verifies a sibling <image.iso>.sha256 if present.

function flash-iso --description 'Write an ISO to a USB drive with dd (interactive)'
    argparse a/all n/dry-run -- $argv
    or return 1

    for cmd in fzf lsblk dd
        if not type -q $cmd
            echo "flash-iso: '$cmd' not found in PATH" >&2
            return 1
        end
    end

    if test (count $argv) -ne 1
        echo "usage: flash-iso [-a|--all] [-n|--dry-run] <image.iso>" >&2
        return 1
    end

    set -l iso $argv[1]
    if not test -f $iso
        echo "flash-iso: not a file: $iso" >&2
        return 1
    end

    set -q _flag_dry_run; and echo "** dry run — nothing will be written **"

    set -l sumfile $iso.sha256
    if test -f $sumfile
        echo "verifying against "(path basename $sumfile)" ..."
        pushd (path dirname $iso)
        sha256sum -c --status (path basename $sumfile)
        set -l ok $status
        popd
        if test $ok -ne 0
            echo "flash-iso: checksum verification failed for $iso" >&2
            return 1
        end
        echo "  checksum OK"
    end

    # Whole disks only; -P keeps MODEL fields with spaces intact.
    set -l rows
    for line in (lsblk -dPno NAME,TRAN,SIZE,MODEL)
        set -l name (string match -rg 'NAME="([^"]*)"' -- $line)
        set -l tran (string match -rg 'TRAN="([^"]*)"' -- $line)
        set -l size (string match -rg 'SIZE="([^"]*)"' -- $line)
        set -l model (string match -rg 'MODEL="([^"]*)"' -- $line)
        test -z "$model"; and set model "(unknown)"
        if not set -q _flag_all; and test "$tran" != usb
            continue
        end
        set -a rows (printf '/dev/%s\t%s\t%s\t%s' $name $size $tran $model)
    end

    if test (count $rows) -eq 0
        if set -q _flag_all
            echo "flash-iso: no block devices found." >&2
        else
            echo "flash-iso: no USB devices found. Plug one in, or pass -a to list all disks." >&2
        end
        return 1
    end

    set -l picked (printf '%s\n' $rows | fzf \
        --delimiter=\t \
        --header='select TARGET device — the whole disk will be ERASED   (ESC to cancel)' \
        --height=40% --reverse --no-multi)
    or begin
        echo "cancelled." >&2
        return 130
    end

    set -l dev (string split \t -- $picked)[1]
    set -l size (string split \t -- $picked)[2]

    echo
    echo "About to write:"
    echo "  image : $iso"
    echo "  device: $dev  ($size)"
    echo
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS $dev
    echo

    set -l mounted
    for mp in (lsblk -nro MOUNTPOINTS $dev)
        test -n "$mp"; and set -a mounted $mp
    end

    for mp in $mounted
        if contains -- $mp / /boot /boot/efi /efi /home /var /var/log /var/cache /usr
            echo "flash-iso: $dev holds a mounted system path ($mp). Refusing to touch it." >&2
            return 1
        end
    end

    if test (count $mounted) -gt 0
        echo "these partitions are mounted:"
        printf '  %s\n' $mounted
        if set -q _flag_dry_run
            for mp in $mounted
                echo "[dry-run] would run: sudo umount $mp"
            end
        else
            read -l -P "unmount them now? [y/N] " ans
            if test "$ans" = y -o "$ans" = Y
                for mp in $mounted
                    sudo umount $mp
                    or begin
                        echo "flash-iso: failed to unmount $mp" >&2
                        return 1
                    end
                end
            else
                echo "aborting: unmount first." >&2
                return 1
            end
        end
    end

    if set -q _flag_dry_run
        echo "[dry-run] would run: sudo dd if=$iso of=$dev bs=4M status=progress oflag=sync"
        echo "dry run complete — no changes made."
        return 0
    end

    read -l -P "type the device path to confirm ERASE ($dev): " confirm
    if test "$confirm" != "$dev"
        echo "aborted (got '$confirm')." >&2
        return 1
    end

    echo "writing $iso -> $dev ..."
    sudo dd if=$iso of=$dev bs=4M status=progress oflag=sync
    or begin
        echo "flash-iso: dd failed" >&2
        return 1
    end
    sudo sync

    echo "done. it is now safe to remove $dev."
end
