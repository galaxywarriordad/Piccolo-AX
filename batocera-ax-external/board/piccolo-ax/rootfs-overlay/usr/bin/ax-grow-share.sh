#!/bin/sh
# /usr/bin/ax-grow-share.sh — Expand SHARE partition on 64 GB / 128 GB Samsung FIT Plus

set -eu

LABEL_NAME="SHARE"
MIN_FREE_MIB=64

log_info() {
    echo "[Piccolo-AX share-grow] $*"
}

log_warn() {
    echo "[Piccolo-AX share-grow][WARN] $*" >&2
}

share_dev="$(blkid -L "$LABEL_NAME" 2>/dev/null || true)"
if [ -z "$share_dev" ]; then
    log_warn "Label '$LABEL_NAME' not found; skipping expansion."
    exit 0
fi

# Resolve whole block device and partition number (supports /dev/sdX2 and /dev/nvmeXnYpZ)
base_name="$(lsblk -no pkname "$share_dev" 2>/dev/null | head -n1 || true)"
if [ -n "$base_name" ]; then
    disk_dev="/dev/${base_name}"
else
    case "$share_dev" in
        /dev/nvme*p[0-9]*|/dev/mmcblk*p[0-9]*)
            disk_dev="${share_dev%p[0-9]*}"
            ;;
        *)
            disk_dev="${share_dev%%[0-9]*}"
            ;;
    esac
fi

part_num="$(cat "/sys/class/block/$(basename "$share_dev")/partition" 2>/dev/null || true)"
if [ -z "$part_num" ]; then
    part_num="$(echo "$share_dev" | sed -n 's/.*[^0-9]\([0-9][0-9]*\)$/\1/p')"
fi

if [ ! -b "$disk_dev" ] || [ -z "$part_num" ]; then
    log_warn "Unable to resolve parent disk or partition number for '$share_dev'."
    exit 0
fi

# Check free unallocated space at end of physical drive in MiB
free_mib="$(parted -ms "$disk_dev" unit MiB print free 2>/dev/null | awk -F: '$NF ~ /^free;/ {gsub(/MiB/,"",$4); if ($4+0 > max) max=$4+0} END {print max+0}')"
if [ "${free_mib:-0}" -lt "$MIN_FREE_MIB" ]; then
    log_info "SHARE ($share_dev) already uses available space on $disk_dev (${free_mib:-0} MiB free)."
    exit 0
fi

was_mounted=0
if grep -qs "^${share_dev}[[:space:]]" /proc/mounts; then
    was_mounted=1
fi

log_info "Expanding $share_dev on $disk_dev (${free_mib} MiB unallocated space detected)..."

# Relocate GPT backup header to the end of the 64 GB / 128 GB flash device if sgdisk is present
if command -v sgdisk >/dev/null 2>&1; then
    sgdisk -e "$disk_dev" >/dev/null 2>&1 || true
fi

# Grow partition to 100% of the drive
if command -v parted >/dev/null 2>&1; then
    parted -s -f "$disk_dev" resizepart "$part_num" 100% >/dev/null 2>&1 || true
elif command -v sfdisk >/dev/null 2>&1; then
    echo ", +" | sfdisk -N "$part_num" --no-reread "$disk_dev" >/dev/null 2>&1 || true
fi

partprobe "$disk_dev" 2>/dev/null || blockdev --rereadpt "$disk_dev" 2>/dev/null || true
udevadm settle 2>/dev/null || sleep 1

# Grow the journal-free ext4 filesystem
if [ "$was_mounted" -eq 0 ]; then
    e2fsck -pf "$share_dev" >/dev/null 2>&1 || true
fi

if command -v resize2fs >/dev/null 2>&1; then
    resize2fs "$share_dev" >/dev/null
    log_info "Expanded $LABEL_NAME ($share_dev) successfully."
else
    log_warn "resize2fs not found; partition resized but filesystem still needs resize2fs."
fi
