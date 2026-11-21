#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="$1"
DESKTOP_REPO="${BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH:-}"
DESKTOP_ENABLED=0

if [ -n "${DESKTOP_REPO}" ] && [ -d "${DESKTOP_REPO}" ]; then
    if [ -n "${BR2_CONFIG:-}" ] && [ -f "${BR2_CONFIG}" ]; then
        if grep -q '^BR2_PACKAGE_PICCOLO_AX_DESKTOP=y$' "${BR2_CONFIG}"; then
            DESKTOP_ENABLED=1
        fi
    else
        DESKTOP_ENABLED=1
    fi
fi

echo "[Piccolo-AX] Pruning unused GPU compute, LLVM, audio, and desktop bloat..."

# 1. Strip unused NVIDIA compute/AI/encoding blobs (~200+ MB)
rm -f "${TARGET_DIR}/usr/lib/libcuda.so" \
      "${TARGET_DIR}/usr/lib/libnvidia-ptxjitcompiler.so" \
      "${TARGET_DIR}/usr/lib/libnvidia-nvvm.so" \
      "${TARGET_DIR}/usr/lib/libnvidia-opencl.so" \
      "${TARGET_DIR}/usr/lib/libnvidia-optix.so" \
      "${TARGET_DIR}/usr/lib/libnvidia-encode.so" \
      "${TARGET_DIR}/usr/lib/libnvidia-fbc.so" \
      "${TARGET_DIR}/usr/lib/libnvidia-ml.so"

# 2. Strip Mesa Gallium software rasterizers & target LLVM runtime (~100+ MB)
rm -f "${TARGET_DIR}/usr/lib/libLLVM"*.so* \
      "${TARGET_DIR}/usr/lib/dri/llvmpipe_dri.so" \
      "${TARGET_DIR}/usr/lib/dri/swrast_dri.so" \
      "${TARGET_DIR}/usr/lib/dri/radeonsi_dri.so" \
      "${TARGET_DIR}/usr/lib/dri/nouveau_dri.so" \
      "${TARGET_DIR}/usr/lib/libvulkan_lvp.so" \
      "${TARGET_DIR}/usr/lib/libvulkan_radeon.so" \
      "${TARGET_DIR}/usr/lib/libvulkan_nouveau.so"

# 3. Purge user-space audio servers, window managers & background daemons
rm -rf "${TARGET_DIR}/usr/bin/pipewire" \
       "${TARGET_DIR}/usr/bin/wireplumber" \
       "${TARGET_DIR}/usr/bin/pulseaudio" \
       "${TARGET_DIR}/usr/sbin/avahi-daemon" \
       "${TARGET_DIR}/usr/sbin/bluetoothd" \
       "${TARGET_DIR}/usr/sbin/smbd" \
       "${TARGET_DIR}/usr/sbin/nmbd" \
       "${TARGET_DIR}/usr/sbin/rngd"

if [ "${DESKTOP_ENABLED}" -eq 0 ]; then
    rm -rf "${TARGET_DIR}/usr/bin/openbox"*
else
    echo "[Piccolo-AX] Installing piccolo-ax-desktop workbench launchers..."
    install -d -m 0755 "${TARGET_DIR}/etc/profile.d" "${TARGET_DIR}/usr/local/bin"
    install -m 0644 "${DESKTOP_REPO}/overlays/common/etc/profile.d/ax-desktop-xdg.sh" \
        "${TARGET_DIR}/etc/profile.d/ax-desktop-xdg.sh"
    install -m 0755 "${DESKTOP_REPO}/scripts/launch-desktop.sh" \
        "${TARGET_DIR}/usr/local/bin/launch-desktop.sh"
    install -m 0755 "${DESKTOP_REPO}/scripts/launch-falkon.sh" \
        "${TARGET_DIR}/usr/local/bin/launch-falkon.sh"
    install -m 0755 "${DESKTOP_REPO}/scripts/stage-share-apps.sh" \
        "${TARGET_DIR}/usr/local/bin/stage-share-apps.sh"
    install -m 0755 "${DESKTOP_REPO}/scripts/launch-mtpaint.sh" \
        "${TARGET_DIR}/usr/local/bin/mtpaint"
fi

# 4. Ensure init hooks are executable
chmod +x "${TARGET_DIR}/etc/init.d/S01piccolo-isolate" \
         "${TARGET_DIR}/etc/init.d/S02piccolo-hw" \
         "${TARGET_DIR}/etc/init.d/K01piccolo-sync" \
         "${TARGET_DIR}/usr/bin/verify_ax_appliance.sh" 2>/dev/null || true
