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

# Resolve whole block device and partition number (supports /dev/sdX2, /dev/nvmeXnYpZ, /dev/mmcblkXpY)
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

part_sys="/sys/class/block/$(basename "$share_dev")/partition"
if [ -r "$part_sys" ]; then
    part_num="$(cat "$part_sys" 2>/dev/null || true)"
else
    part_num="$(echo "$share_dev" | sed -n 's/.*[^0-9]\([0-9][0-9]*\)$/\1/p')"
fi

if [ ! -b "$disk_dev" ] || [ -z "$part_num" ]; then
    log_warn "Unable to resolve parent disk or partition number for '$share_dev'."
    exit 0
fi

# Inspect free space in MiB; specifically detect free space at end of device if reported
free_mib=0
if command -v parted >/dev/null 2>&1; then
    free_mib="$(parted -ms "$disk_dev" unit MiB print free 2>/dev/null | awk -F: '
        $NF ~ /^free;/ {
            val = $4
            sub(/MiB$/, "", val)
            if ((val + 0) > max) max = (val + 0)
        }
        END { print max + 0 }
    ')"
fi

if [ "${free_mib:-0}" -lt "$MIN_FREE_MIB" ]; then
    log_info "SHARE ($share_dev) already uses available space on $disk_dev (${free_mib:-0} MiB free)."
    exit 0
fi

was_mounted=0
if grep -qs "^${share_dev}[[:space:]]" /proc/mounts; then
    was_mounted=1
fi

log_info "Expanding $share_dev on $disk_dev (${free_mib} MiB unallocated space detected)..."

# Relocate GPT backup header to the end of the 64 GB / 128 GB flash device before resizing
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

# Refresh blkid cache and re-resolve device node if needed
blkid -g >/dev/null 2>&1 || true
refreshed_dev="$(blkid -L "$LABEL_NAME" 2>/dev/null || true)"
if [ -n "$refreshed_dev" ]; then
    share_dev="$refreshed_dev"
fi

# Grow the journal-free ext4 filesystem
if [ "$was_mounted" -eq 0 ]; then
    e2fsck -pf "$share_dev" >/dev/null 2>&1 || true
fi

if command -v resize2fs >/dev/null 2>&1; then
    resize2fs "$share_dev" >/dev/null
    udevadm settle 2>/dev/null || true
    log_info "Expanded $LABEL_NAME ($share_dev) successfully."
else
    log_warn "resize2fs not found; partition resized but filesystem still needs resize2fs."
fi
```[cite: 17]

### Key Optimizations Made
* **Safer `sysfs` lookup under `set -u`:** Checks `[ -r "$part_sys" ]` before reading `/sys/class/block/.../partition` so missing `sysfs` entries never fail unexpectedly under `set -u`[cite: 17].
* **Clean `awk` numeric extraction:** Strips the trailing `MiB` suffix cleanly (`sub(/MiB$/, "", val)`) before comparing against `MIN_FREE_MIB`[cite: 17].
* **`blkid -g` & `udevadm settle` refresh:** Refreshes `blkid` and settles `udev` after partition table re-read and `resize2fs` so downstream mount scripts see the expanded `SHARE` device cleanly[cite: 17].

### Quick Verification Steps
1. **Before running:** Check `blkid -L SHARE` and `lsblk -o NAME,SIZE,FSTYPE,LABEL` on your Samsung FIT Plus (`64 GB` or `128 GB`) to confirm `SHARE` maps to the intended partition[cite: 17].
2. **First run:** Execute `/usr/bin/ax-grow-share.sh` (or boot with it called after `e2fsck` in `S01piccolo-isolate`) and verify `df -h /userdata` reflects the grown capacity[cite: 17].
3. **Second run:** Execute `/usr/bin/ax-grow-share.sh` again and verify it prints `already uses available space` and exits `0`[cite: 17].

Would you like to review `K01piccolo-sync` next to verify atomic cache and PGO flushes onto the expanded `SHARE` partition?
