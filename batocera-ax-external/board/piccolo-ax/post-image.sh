#!/usr/bin/env bash
set -euo pipefail

BINARIES_DIR="$1"
TARGET_DIR="${TARGET_DIR:-${BINARIES_DIR}/../target}"
EROFS_OUT="${BINARIES_DIR}/rootfs.erofs"
MAX_EROFS_KB=524288

echo "[Piccolo-AX] Packing EROFS (lz4hc,9) image..."
rm -f "${EROFS_OUT}"
mkfs.erofs -zlz4hc,9 -T0 --force-uid=0 --force-gid=0 "${EROFS_OUT}" "${TARGET_DIR}"

ACTUAL_KB=$(du -k "${EROFS_OUT}" | cut -f1)
echo "[Piccolo-AX] rootfs.erofs size: ${ACTUAL_KB} KB / ${MAX_EROFS_KB} KB budget"

if [ "${ACTUAL_KB}" -gt "${MAX_EROFS_KB}" ]; then
    echo "ERROR: rootfs.erofs (${ACTUAL_KB} KB) exceeds 512 MB toram budget!"
    du -ah "${TARGET_DIR}" | sort -rh | head -n 15
    exit 1
fi
