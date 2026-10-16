# flash-iso [-a|--all] [-n|--dry-run] [-h|--help] <image>
# Write an ISO or IMG (optionally XZ-compressed) to a whole USB disk.
# USB-only unless --all; --dry-run writes nothing. Verifies <image>.sha256 if present.

function __flash_iso_usage
    echo 'usage: flash-iso [-a|--all] [-n|--dry-run] [-h|--help] <image>

Write an ISO or IMG to a whole USB disk with dd. The target is picked
interactively with fzf.

options:
  -a, --all      list every whole disk, not just USB ones
  -n, --dry-run  show what would happen; write nothing
  -h, --help     show this help

notes:
  - .xz images are checked and decompressed while writing.
  - a sibling <image>.sha256 is verified first if it exists.

examples:
  flash-iso archlinux.iso        # pick a USB disk and write to it
  flash-iso haos.img.xz          # decompress and write an XZ image
  flash-iso -n archlinux.iso     # rehearse without writing
  flash-iso --all archlinux.iso  # also offer non-USB disks'
end

function flash-iso --description 'Write an ISO or IMG, including .xz, to a USB drive (interactive)'
    argparse h/help a/all n/dry-run -- $argv
    or begin
        __flash_iso_usage >&2
        return 1
    end

    if set -q _flag_help
        __flash_iso_usage
        return 0
    end

    for cmd in fzf lsblk dd
        if not type -q $cmd
            echo "flash-iso: '$cmd' not found in PATH" >&2
            return 1
        end
    end

    if test (count $argv) -ne 1
        __flash_iso_usage >&2
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

    set -l compressed 0
    if string match -qi '*.xz' -- "$iso"
        set compressed 1
        if not type -q xz
            echo "flash-iso: 'xz' not found in PATH" >&2
            return 1
        end
        echo "checking XZ image integrity ..."
        xz -t -- "$iso"
        or begin
            echo "flash-iso: XZ integrity check failed for $iso" >&2
            return 1
        end
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
        if test $compressed -eq 1
            echo "[dry-run] would run: xz -dc -- "(string escape -- "$iso")" | sudo dd of=$dev bs=4M iflag=fullblock status=progress oflag=sync"
        else
            echo "[dry-run] would run: sudo dd if="(string escape -- "$iso")" of=$dev bs=4M status=progress oflag=sync"
        end
        echo "dry run complete — no changes made."
        return 0
    end

    read -l -P "type the device path to confirm ERASE ($dev): " confirm
    if test "$confirm" != "$dev"
        echo "aborted (got '$confirm')." >&2
        return 1
    end

    echo "writing $iso -> $dev ..."
    if test $compressed -eq 1
        # Authenticate before starting the pipeline; check both processes afterward.
        sudo -v
        or return 1
        xz -dc -- "$iso" | sudo dd of=$dev bs=4M iflag=fullblock status=progress oflag=sync
        set -l write_status $pipestatus
        if test "$write_status[1]" -ne 0; or test "$write_status[2]" -ne 0
            echo "flash-iso: decompression or disk write failed" >&2
            return 1
        end
    else
        sudo dd if=$iso of=$dev bs=4M status=progress oflag=sync
        or begin
            echo "flash-iso: dd failed" >&2
            return 1
        end
    end
    sudo sync
    or begin
        echo "flash-iso: sync failed" >&2
        return 1
    end

    echo "done. it is now safe to remove $dev."
end
