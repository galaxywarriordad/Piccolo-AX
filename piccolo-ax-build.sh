#!/usr/bin/env bash
set -euo pipefail

# Piccolo-AX build & appliance staging script
# Enforces canonical Piccolo-AX / piccolo-ax-desktop naming, AX-SDK resolution,
# and strict separation between real-time appliance mode and desktop mode.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." 2>/dev/null || pwd)"
AX_SDK_DIR="${AX_SDK_DIR:-${REPO_ROOT}/ax-sdk}"
DESKTOP_REPO_DIR="${DESKTOP_REPO_DIR:-${REPO_ROOT}/piccolo-ax-desktop}"
SHARE_DIR="${SHARE_DIR:-/userdata/system/piccolo-ax}"
JOBS="${JOBS:-4}"
MODE="${1:-appliance}" # appliance | desktop

# Guard against legacy double-L "Picollo" paths if encountered
for candidate in "${REPO_ROOT}/../Picollo-AX" "${REPO_ROOT}/../picollo-ax-desktop"; do
    if [[ -d "${candidate}" ]]; then
        echo "[WARN] Found legacy 'Picollo' directory: ${candidate} (canonical name uses single 'l': Piccolo-AX / piccolo-ax-desktop)" >&2
    fi
done

if [[ ! -d "${AX_SDK_DIR}" ]]; then
    echo "[ERROR] ax-sdk not found at '${AX_SDK_DIR}'. Set AX_SDK_DIR to your local ax-sdk checkout." >&2
    exit 1
fi

case "${MODE}" in
    appliance)
        echo "[Piccolo-AX] Mode: appliance (real-time 6.12-rt / core-isolated / audio-first)"
        echo "[Piccolo-AX] Using AX_SDK_DIR=${AX_SDK_DIR} (jobs=${JOBS})"
        ;;
    desktop)
        echo "[Piccolo-AX] Mode: desktop (opt-in piccolo-ax-desktop companion; isolated from RT cores)"
        if [[ -d "${DESKTOP_REPO_DIR}" ]]; then
            echo "[Piccolo-AX] Desktop repo: ${DESKTOP_REPO_DIR}"
        else
            echo "[INFO] piccolo-ax-desktop not found at '${DESKTOP_REPO_DIR}' yet."
        fi
        mkdir -p "${SHARE_DIR}/desktop"
        echo "[Piccolo-AX] Desktop persistence target: ${SHARE_DIR}/desktop"
        ;;
    *)
        echo "Usage: $0 [appliance|desktop]" >&2
        exit 2
        ;;
esac
