#!/usr/bin/env bash
set -euo pipefail

BINARIES_DIR="${1:?Usage: $0 <binaries_dir>}"
BOARD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${TARGET_DIR:-${BINARIES_DIR}/../target}"

EROFS_OUT="${BINARIES_DIR}/rootfs.erofs"
BOOT_STAGE="${BINARIES_DIR}/boot-fat32"
BOOT_IMG="${BINARIES_DIR}/boot.vfat"
SHARE_IMG="${BINARIES_DIR}/share.ext4"
DISK_IMG="${BINARIES_DIR}/piccolo-ax-x86_64.img"

# 512 MiB ceiling for RAM-resident EROFS rootfs
MAX_EROFS_KB=524288
# 4.0 GiB FAT32 BATOCERA partition + 1.0 GiB base SHARE partition image
BOOT_PART_MIB=4096
SHARE_PART_MIB=1024

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "ERROR: Required host tool '$1' not found in PATH."
        exit 1
    fi
}

require_cmd mkfs.erofs
require_cmd mkfs.vfat
require_cmd mkfs.ext4
require_cmd mcopy
require_cmd mmd
require_cmd parted
require_cmd truncate

if [ ! -d "${TARGET_DIR}" ]; then
    echo "ERROR: Target rootfs directory '${TARGET_DIR}' does not exist."
    exit 1
fi

if [ ! -f "${BOARD_DIR}/limine.conf" ]; then
    echo "ERROR: Missing required bootloader config '${BOARD_DIR}/limine.conf'."
    exit 1
fi

echo "[Piccolo-AX] Packing EROFS (lz4hc,9) rootfs image..."
rm -f "${EROFS_OUT}"
mkfs.erofs -zlz4hc,9 -T0 --force-uid=0 --force-gid=0 "${EROFS_OUT}" "${TARGET_DIR}"

ACTUAL_KB=$(du -k "${EROFS_OUT}" | cut -f1)
echo "[Piccolo-AX] rootfs.erofs size: ${ACTUAL_KB} KB / ${MAX_EROFS_KB} KB budget"

if [ "${ACTUAL_KB}" -gt "${MAX_EROFS_KB}" ]; then
    echo "ERROR: rootfs.erofs (${ACTUAL_KB} KB) exceeds 512 MB toram budget!"
    du -ah "${TARGET_DIR}" | sort -rh | head -n 15
    exit 1
fi

echo "[Piccolo-AX] Staging FAT32 boot payload (Limine + kernel + EROFS)..."
rm -rf "${BOOT_STAGE}"
mkdir -p "${BOOT_STAGE}/EFI/BOOT" "${BOOT_STAGE}/boot"

if [ -f "${BINARIES_DIR}/EFI/BOOT/BOOTX64.EFI" ]; then
    cp -f "${BINARIES_DIR}/EFI/BOOT/BOOTX64.EFI" "${BOOT_STAGE}/EFI/BOOT/BOOTX64.EFI"
else
    echo "WARN: ${BINARIES_DIR}/EFI/BOOT/BOOTX64.EFI not found (verify BR2_PACKAGE_LIMINE=y)."
fi

if [ -f "${BINARIES_DIR}/limine-bios.sys" ]; then
    cp -f "${BINARIES_DIR}/limine-bios.sys" "${BOOT_STAGE}/limine-bios.sys"
fi

if [ -f "${BINARIES_DIR}/bzImage" ]; then
    cp -f "${BINARIES_DIR}/bzImage" "${BOOT_STAGE}/boot/bzImage"
else
    echo "WARN: ${BINARIES_DIR}/bzImage not found in ${BINARIES_DIR}."
fi

if [ -f "${BINARIES_DIR}/initrd.lz4" ]; then
    cp -f "${BINARIES_DIR}/initrd.lz4" "${BOOT_STAGE}/boot/initrd.lz4"
fi

cp -f "${BOARD_DIR}/limine.conf" "${BOOT_STAGE}/limine.conf"
cp -f "${EROFS_OUT}" "${BOOT_STAGE}/boot/rootfs.erofs"

echo "[Piccolo-AX] Building ${BOOT_PART_MIB} MiB FAT32 (BATOCERA) partition image..."
rm -f "${BOOT_IMG}"
truncate -s "${BOOT_PART_MIB}M" "${BOOT_IMG}"
mkfs.vfat -F 32 -n "BATOCERA" "${BOOT_IMG}" >/dev/null
mmd -i "${BOOT_IMG}" ::/EFI ::/EFI/BOOT ::/boot
mcopy -i "${BOOT_IMG}" -s "${BOOT_STAGE}/"* ::/

echo "[Piccolo-AX] Building ${SHARE_PART_MIB} MiB ext4 (^has_journal, SHARE) partition image..."
rm -f "${SHARE_IMG}"
truncate -s "${SHARE_PART_MIB}M" "${SHARE_IMG}"
mkfs.ext4 -F -L "SHARE" -O ^has_journal "${SHARE_IMG}" >/dev/null

echo "[Piccolo-AX] Assembling GPT disk image '${DISK_IMG}'..."
TOTAL_MIB=$((1 + BOOT_PART_MIB + SHARE_PART_MIB))
rm -f "${DISK_IMG}"
truncate -s "${TOTAL_MIB}M" "${DISK_IMG}"

parted -s "${DISK_IMG}" mklabel gpt
parted -s "${DISK_IMG}" mkpart "BATOCERA" fat32 1MiB "$((1 + BOOT_PART_MIB))MiB"
parted -s "${DISK_IMG}" set 1 esp on
parted -s "${DISK_IMG}" mkpart "SHARE" ext4 "$((1 + BOOT_PART_MIB))MiB" 100%

BOOT_START_BYTES=$((1 * 1024 * 1024))
SHARE_START_BYTES=$(((1 + BOOT_PART_MIB) * 1024 * 1024))

dd if="${BOOT_IMG}" of="${DISK_IMG}" bs=1M seek=1 conv=notrunc status=none
dd if="${SHARE_IMG}" of="${DISK_IMG}" bs=1M seek="$((1 + BOOT_PART_MIB))" conv=notrunc status=none

if command -v limine >/dev/null 2>&1 && [ -f "${BINARIES_DIR}/limine-bios.sys" ]; then
    limine bios-install "${DISK_IMG}" >/dev/null 2>&1 || true
fi

echo "[Piccolo-AX] Image build complete: ${DISK_IMG}"
echo "  Partition 1 (BATOCERA, FAT32): offset ${BOOT_START_BYTES} bytes (${BOOT_PART_MIB} MiB)"
echo "  Partition 2 (SHARE, ext4 ^has_journal): offset ${SHARE_START_BYTES} bytes (${SHARE_PART_MIB} MiB)"
