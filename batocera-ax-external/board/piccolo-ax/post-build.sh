#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="$1"

echo "[Piccolo-AX] Pruning unused GPU compute, LLVM, audio, and desktop bloat..."

# 1. Strip unused NVIDIA compute/AI/encoding blobs (~200+ MB)
rm -f "${TARGET_DIR}"/usr/lib/libcuda.so* \
      "${TARGET_DIR}"/usr/lib/libnvidia-ptxjitcompiler.so* \
      "${TARGET_DIR}"/usr/lib/libnvidia-nvvm.so* \
      "${TARGET_DIR}"/usr/lib/libnvidia-opencl.so* \
      "${TARGET_DIR}"/usr/lib/libnvidia-optix.so* \
      "${TARGET_DIR}"/usr/lib/libnvidia-encode.so* \
      "${TARGET_DIR}"/usr/lib/libnvidia-fbc.so* \
      "${TARGET_DIR}"/usr/lib/libnvidia-ml.so*

# 2. Strip Mesa Gallium software rasterisers & target LLVM runtime (~100+ MB)
rm -f "${TARGET_DIR}"/usr/lib/libLLVM*.so* \
      "${TARGET_DIR}"/usr/lib/dri/llvmpipe_dri.so \
      "${TARGET_DIR}"/usr/lib/dri/swrast_dri.so \
      "${TARGET_DIR}"/usr/lib/dri/radeonsi_dri.so \
      "${TARGET_DIR}"/usr/lib/dri/nouveau_dri.so \
      "${TARGET_DIR}"/usr/lib/libvulkan_lvp.so \
      "${TARGET_DIR}"/usr/lib/libvulkan_radeon.so \
      "${TARGET_DIR}"/usr/lib/libvulkan_nouveau.so

# 3. Purge user-space audio servers, window managers & background daemons
rm -rf "${TARGET_DIR}"/usr/bin/pipewire* \
       "${TARGET_DIR}"/usr/bin/wireplumber* \
       "${TARGET_DIR}"/usr/bin/pulseaudio* \
       "${TARGET_DIR}"/usr/bin/openbox* \
       "${TARGET_DIR}"/usr/sbin/avahi-daemon \
       "${TARGET_DIR}"/usr/sbin/bluetoothd \
       "${TARGET_DIR}"/usr/sbin/smbd \
       "${TARGET_DIR}"/usr/sbin/nmbd \
       "${TARGET_DIR}"/usr/sbin/rngd

# 4. Ensure init hooks are executable
chmod +x "${TARGET_DIR}"/etc/init.d/S01piccolo-isolate \
         "${TARGET_DIR}"/etc/init.d/S02piccolo-hw \
         "${TARGET_DIR}"/etc/init.d/K01piccolo-sync \
         "${TARGET_DIR}"/usr/bin/verify_ax_appliance.sh 2>/dev/null || true
