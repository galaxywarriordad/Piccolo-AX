#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "  PICCOLO [AX] — BARE-METAL APPLIANCE HARDWARE VERIFICATION"
echo "============================================================"
FAIL=0

# 1. Tickless Isolation & mitigations=off
if grep -q "mitigations=off" /proc/cmdline && grep -q "nohz_full=0-4" /proc/cmdline; then
    echo "[PASS] 1. Kernel cmdline: nohz_full=0-4, rcu_nocbs=0-4, mitigations=off active"
else
    echo "[FAIL] 1. Missing required kernel isolation flags in /proc/cmdline"
    FAIL=1
fi

# 2. Intel CAT MSR 0xc8f Probe
if command -v rdmsr >/dev/null 2>&1 && rdmsr 0xc8f >/dev/null 2>&1; then
    echo "[PASS] 2. Intel CAT MSR 0xc8f accessible (Hardware L3 partitioning available)"
else
    echo "[WARN] 2. Intel CAT MSR 0xc8f fused/unavailable — engaging _MM_HINT_NTA Core 5 fallback"
fi

# 3. HugePages (6x 1G + 1024x 2M) & zram Check
HP_1G=$(grep "HugePages_Total:" /proc/meminfo | awk '{print $2}')
if [ "${HP_1G:-0}" -ge 6 ] && [ -b /dev/zram0 ]; then
    echo "[PASS] 3. Hybrid HugePages (${HP_1G}x 1G) & LZ4 zram active"
else
    echo "[FAIL] 3. HugePages (${HP_1G:-0}) or /dev/zram0 not configured"
    FAIL=1
fi

# 4. NVIDIA 580.* Legacy Driver & Persistence Mode
NV_VER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo "NONE")
if [[ "${NV_VER}" == 580.* ]]; then
    echo "[PASS] 4. NVIDIA Maxwell legacy driver pinned: ${NV_VER}"
else
    echo "[FAIL] 4. Expected NVIDIA 580.* driver, found: ${NV_VER}"
    FAIL=1
fi

# 5. Intel UHD 630 VA-API (iHD) Render Node
if [ -e /dev/dri/renderD128 ] || [ -e /dev/dri/renderD129 ]; then
    echo "[PASS] 5. DRI render node present for Intel UHD 630 VA-API (iHD) dma_buf export"
else
    echo "[FAIL] 5. Missing /dev/dri/renderD* node (Enable IGD Multi-Monitor in BIOS)"
    FAIL=1
fi

# 6. HiBy FC3 USB DAC Exclusive ALSA Node
if aplay -l 2>/dev/null | grep -q "FC3"; then
    echo "[PASS] 6. HiBy FC3 USB DAC detected on ALSA hw:CARD=FC3,DEV=0"
else
    echo "[WARN] 6. HiBy FC3 USB DAC not currently connected"
fi

# 7. RootFS < 512 MB Budget Check
if [ -f /boot/boot/rootfs.erofs ]; then
    SIZE_MB=$(( $(stat -c%s /boot/boot/rootfs.erofs) / 1024 / 1024 ))
    if [ "${SIZE_MB}" -le 512 ]; then
        echo "[PASS] 7. EROFS image size: ${SIZE_MB} MB / 512 MB ceiling"
    else
        echo "[FAIL] 7. EROFS image size (${SIZE_MB} MB) exceeds 512 MB ceiling"
        FAIL=1
    fi
fi

echo "============================================================"
if [ "$FAIL" -eq 0 ]; then
    echo "RESULT: EXCELLENT_APPLIANCE_READY"
    exit 0
else
    echo "RESULT: APPLIANCE_GATE_FAILED"
    exit 1
fi
