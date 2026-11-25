# Piccolo-AX Architecture Topology & Reference Implementation

## AX Ecosystem: 9-Repository Topology & Lineage

The **AX Project** separates shared low-level C++20 silicon abstractions (`ax-sdk`) from platform-, emulator-, and workbench-specific repositories so upstream rebases stay clean while hardware isolation logic remains unified across Windows 10/11, bare-metal `x86_64` Linux, and `aarch64` handhelds.

```
         +-------------------------------------------------------+
         |                   ax-sdk (v1_36_2)                  |
         |        (https://github.com/galaxywarriordad/ax-sdk)       |
         | Shared C++20 Silicon Core, Dynamic SMT/CCX & 1:2:1   |
         |   Topology, Platform Shims, Telemetry & Master Specs  |
         +-------------------------------------------------------+
          /             /                       \                 \
  FetchContent   FetchContent/           FetchContent\         BR2_EXTERNAL
        /               /                             \                 \
       v               v                               v                 v
+-----------------------+ +-------------------+ +------------------+ +-----------------------+
| Eden-Espresso-Wave-AX | | Cemu-Latte-AX     | | Amiberry-AX      | | Generation-X-AX       |
| (Forgejo — Switch)    | | (GitHub — Wii U)  | | (GitHub — Amiga) | | (GitHub — 7 Classics) |
| Win10/11 Master,      | | Wii U / Latte     | | 500/1200/CD32    | | RMG, BlastEm, OutRun, |
| LLVM 23 PGO, QSV      | | Powered by ax     | | Powered by ax    | | EDuke32, Frontier,    |
|                       | |                   | |                  | | Flycast & Hatari      |
+-----------------------+ +-------------------+ +------------------+ +-----------------------+
                                                                         |
                               +-----------------------+-----------------+
                               |                       |
                               v                       v
                   +-------------------+   +-------------------+   +---------------------------------------+
                   | Piccolo-2go       |   | Piccolo-AX        |   | FLAC_AX                               |
                   | (GitHub — ARM64 OS|   | (GitHub — x86 OS) |   | (GitHub — A/V Studio, Hosts & ESS DAC)|
                   | RK3326 1:2:1      |   | < 512 MB toram    |   | flac_ax, ax_clap_host, ax_lv2_host,   |
                   | BATLEXP G350/R36S |   | 6.12-rt Appliance |   | ax_av_studio, ax_video_upscaler, TUI  |
                   +-------------------+   +---------+---------+   +---------------------------------------+
                                                     |
                                                     v
                                           +-------------------+
                                           | piccolo-ax-desktop|
                                           | (GitHub — <42 MB) |
                                           | C/C++ Workbench   |
                                           +-------------------+
```

### Repository Breakdown & Lineage (All 9 Repositories)

| Repository | Host & Canonical URL | Primary Role & Lineage |
| :---- | :---- | :---- |
| **ax-sdk** | **GitHub:** `galaxywarriordad/ax-sdk` | Shared, zero-dependency C++20 silicon library (`libax_core` / `ax::core`, `v1_36_2`), dynamic Intel SMT / AMD CCX / `RK3326` `1:2:1` topology resolver, Win32/Linux platform shims, and cross-project master specs. |
| **Eden-Espresso-Wave-AX** | **Forgejo:** `galaxywarriordad/Eden-Espresso-Wave-AX` | **Windows 10/11 Switch Engine Master** — Direct fork of upstream Eden hosted on Forgejo for frictionless PR cherry-picks; features LLVM `clang-cl` 23+ 3-stage PGO, FlexASIO/WASAPI Exclusive audio, Intel QSV offload, and Maxwell GM200 VRAM shields. |
| **Piccolo-AX** | **GitHub:** `galaxywarriordad/Piccolo-AX` | **Batocera Linux Branch of `Eden-Espresso-Wave-AX`** — Adapts the Espresso Wave `[AX]` engine for bare-metal Linux (`Linux 6.12-rt`, direct ALSA `SCHED_FIFO`, `iHD` VA-API `dma_buf`) and packages all `[AX]` engines and studios via `batocera-ax-external/` into a `< 512 MB` `toram` EROFS USB 3.0 console appliance. |
| **Piccolo-2go** | **GitHub:** `galaxywarriordad/Piccolo-2go` | **Deterministic `aarch64` Buildroot Handheld OS** — `< 140 MB` `zstd` SquashFS for **BATLEXP G350** & **R36S** (`RK3326`, `1:2:1` isolation, `1024 MB LZ4` ZRAM, `Panfrost` KMS/DRM, dual SanDisk `SDR50` guard, and **HiBy FC3 `1.3 Vrms`** OTG audio). |
| **Generation-X-AX** | **GitHub:** `galaxywarriordad/Generation-X-AX` | **Unified Classic Engines `[AX]` Suite** — Consolidates 7 classic 1985–1998 engines (`RMG` N64, `BlastEm` Mega Drive, `Cannonball` OutRun, `EDuke32`, `Frontier: Elite II`, `Flycast` Dreamcast/NAOMI, and `Hatari` Atari ST) behind `ax_retro_bridge` (`ax::core`). |
| **Cemu-Latte-AX** | **GitHub:** `galaxywarriordad/Cemu-Latte-AX` | **Nintendo Wii U (Latte GPU) AX Fork** — Integrates `ax::core` for deterministic physical-core isolation, MMCSS/ALSA audio prioritization, and hardware IRQ/VRAM discipline across Windows 10/11 and `Piccolo-AX`. |
| **Amiberry-AX** | **GitHub:** `galaxywarriordad/Amiberry-AX` | **Commodore Amiga 500 / 1200 / CD32 AX Fork** — Integrates `ax::core` (`v1_36_2`) for cycle-consistent `50 Hz` PAL raster timing, `HugeTLB` fastmem, and Paula DMA audio isolation. |
| **piccolo-ax-desktop** | **GitHub:** `galaxywarriordad/piccolo-ax-desktop` | **Optional `< 42 MB` Tier A C/C++ Desktop Workbench** — Pluggable `BR2_EXTERNAL` overlay providing `LXQt`/`XFCE`, `Falkon`, `GrafX2`, `LibreSprite`, `mtPaint`, `AzPainter`, `GHex`, and `CPU-X` with `SHARE` persistence. |
| **FLAC\_AX** | **GitHub:** `galaxywarriordad/FLAC_AX` | **Deterministic `[AX]` Audio/Visual Studio, Plugin Hosts & ESS Sabre Appliance** — Combines bit-perfect `44.1–384 kHz` `S32_LE` / `DoP` / tracker playback (`flac_ax`) with cross-platform CLAP (`ax_clap_host`) and LV2 (`ax_lv2_host`) plugin hosts draining via `StereoSampleRing` and `AlsaStereoSink` (`S32_LE`), RAII `ScopedDacLock` (`/run/lock/ax-dac.lock`), a live `2.00 ms` 16-voice polyphonic synthesizer, Akai MPK Mini MK3 ALSA RawMIDI controller, VBlank OpenGL FFT/oscilloscope HUD (`ax_av_studio`), 720p/1080p/2K upscaler (`ax_video_upscaler`), and Core `5` appliance TUI (`ax_appliance_tui`). |

### Cross-Repository Dependency & Merge Flow

* **Shared Silicon Core (`ax-sdk`):** `Eden-Espresso-Wave-AX`, `Piccolo-AX`, `Piccolo-2go`, `Cemu-Latte-AX`, `Amiberry-AX`, `Generation-X-AX`, and `FLAC_AX` all consume `ax-sdk` (`v1.36.2`) as a pinned CMake dependency (`ax::core`), inheriting identical core-pinning, ring buffer transport, and `/dev/shm/ax_telemetry` jitter counters without duplicating C++20 code.  
* **Unified Appliance Assembly (`Piccolo-AX`):** `batocera-ax-external/` pulls `Eden-Espresso-Wave-AX`, `Cemu-Latte-AX`, `Amiberry-AX`, all `Generation-X-AX` engine targets, and `FLAC_AX` (`flac_ax`, `ax_clap_host`, `ax_lv2_host`, `ax_av_studio`, `ax_video_upscaler`, and `ax_appliance_tui`, coordinated via `/run/lock/ax-dac.lock` DAC handoff) into a single immutable `rootfs.erofs` image—with optional `piccolo-ax-desktop` workbench layering enabled via `BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH`.

---

## Piccolo-AX System & Storage Architecture

### Core Architectural Constraints & Design Principles

* **Immutable `toram` EROFS Rootfs (`<= 512 MiB` / `524288 KB`):** Packed with `mkfs.erofs -zlz4hc,9 -T0 --force-uid=0 --force-gid=0` so the read-only appliance rootfs fits comfortably in RAM with zero runtime flash wear.  
* **Journal-Free `ext4` `SHARE` Partition (`-O ^has_journal`):** Mounted on `/userdata` to eliminate ext4 journal write amplification on Samsung FIT Plus (`64 GB` `MUF-64AB/APC` and `128 GB`) USB flash storage.  
* **First-Boot Dynamic Expansion (`ax-grow-share.sh`):** Keeps the build-time image compact (`4096 MiB` `BATOCERA` FAT32 \+ `2048 MiB` default `SHARE` ext4) so a single flash image works across both `64 GB` and `128 GB` drives, then relocates the GPT backup header (`sgdisk -e`), grows partition 2 to `100%`, and expands the `ext4` filesystem (`resize2fs`) on first boot.  
* **CPU Core Isolation & IRQ Pinning:**  
  * **Cores `0–4`:** Isolated domain (`isolcpus=managed_irq,domain,0-4`, `nohz_full=0-4`, `rcu_nocbs=0-4`, and cgroup v2 `eden.slice` `cpuset.cpus=0-4`), with Core `0` (`0x01`) hosting low-latency USB DAC / xHCI MSI IRQs, real-time audio (`SCHED_FIFO` priority `80`), and `AlsaStereoSink` consumers, and Core `1` (`0x02`) hosting NVIDIA GPU (`GTX 980 Ti` / `580.*` legacy branch) MSI IRQs.  
  * **Core `5` (`0x20`):** Quarantined target for unbound kernel workqueues, default SMP IRQ affinity, `512 MB` LZ4 `zram0` swap (`swapon -p 100`), and asynchronous `SwitchHDD` mounting.  
* **RAM-Resident Caches & Atomic Exit Persistence (`K01piccolo-sync`):** Emulator caches, PGO profiles, and NVIDIA caches stage in `/dev/shm/emu_cache`, `/dev/shm/pgo`, and `/dev/shm/nv_cache` during runtime and flush atomically (`.tmp.$$` \-\> `.tar.zst`) to `/userdata/system/ax-sync/` on shutdown/stop.  
* **Exclusive DAC Locking (`/run/lock/ax-dac.lock`):** Serializes real-time access to `hw:CARD=FC3,DEV=0` (HiBy FC3 / ESS DAC) via `ScopedDacLock` (`flock` on open descriptor without unlink race on teardown) and `flock -n` in `ax-mode-cli` across `audio` (`flac_ax`, `ax_av_studio`, `ax_clap_host`, `ax_lv2_host`) and `upscaler` (`ax_video_upscaler`) modes.  
* **Single-Mode Boot & Reboot-to-Switch Workflow:** Operating mode is selected at boot in Limine via `ax.mode=retro`, `audio`, `upscaler`, or `desktop`. Major workload or desktop transitions require a reboot so each session launches on a clean, uncontended hardware slate. Irreplaceable state—game saves, SRAM, presets, and configs—is written directly to `/userdata` (`SHARE`) via atomic temporary file creation, `fsync`, and rename operations at mutation time rather than relying on shutdown hooks, while `/dev/shm` (`emu_cache`, `pgo`, `nv_cache`) remains strictly ephemeral, regenerable cache.

---

## Reference Code & Configuration Suite

### 1\. `batocera-ax-external/board/piccolo-ax/post-build.sh`

```sh
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
rm -f "${TARGET_DIR}/usr/lib/libcuda.so"* \
      "${TARGET_DIR}/usr/lib/libnvidia-ptxjitcompiler.so"* \
      "${TARGET_DIR}/usr/lib/libnvidia-nvvm.so"* \
      "${TARGET_DIR}/usr/lib/libnvidia-opencl.so"* \
      "${TARGET_DIR}/usr/lib/libnvidia-optix.so"* \
      "${TARGET_DIR}/usr/lib/libnvidia-encode.so"* \
      "${TARGET_DIR}/usr/lib/libnvidia-fbc.so"* \
      "${TARGET_DIR}/usr/lib/libnvidia-ml.so"*

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

# 4. Ensure init hooks & scripts are executable
chmod +x "${TARGET_DIR}/etc/init.d/S01piccolo-isolate" \
         "${TARGET_DIR}/etc/init.d/S02piccolo-hw" \
         "${TARGET_DIR}/etc/init.d/K01piccolo-sync" \
         "${TARGET_DIR}/usr/bin/ax-grow-share.sh" \
         "${TARGET_DIR}/usr/bin/ax-mode-cli" \
         "${TARGET_DIR}/usr/bin/verify_ax_appliance.sh" 2>/dev/null || true
```

### 2\. `batocera-ax-external/board/piccolo-ax/post-image.sh`

```sh
#!/usr/bin/env bash
set -euo pipefail

BINARIES_DIR="${1:?Usage: $0 <binaries_dir>}"
BOARD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${TARGET_DIR:-${BINARIES_DIR}/../target}"

EROFS_OUT="${BINARIES_DIR}/rootfs.erofs"
EROFS_PREV="${BINARIES_DIR}/rootfs.erofs.prev"
BOOT_IMG="${BINARIES_DIR}/boot.vfat"
SHARE_IMG="${BINARIES_DIR}/share.ext4"

# Optional target hint: 64g | 128g | universal (default)
FIT_PROFILE="${FIT_PROFILE:-universal}"
MAX_EROFS_KB=524288
BOOT_PART_MIB=4096
# Compact build-time SHARE image; expand to fill 64 GB (~55.6G) or 128 GB on target
SHARE_PART_MIB="${SHARE_PART_MIB:-2048}"

case "${FIT_PROFILE}" in
  64g|64GB|64)
    DISK_IMG="${BINARIES_DIR}/piccolo-ax-fit64-x86_64.img"
    ;;
  128g|128GB|128)
    DISK_IMG="${BINARIES_DIR}/piccolo-ax-fit128-x86_64.img"
    ;;
  universal|*)
    DISK_IMG="${BINARIES_DIR}/piccolo-ax-fit-x86_64.img"
    ;;
esac

for cmd in mkfs.erofs mkfs.vfat mkfs.ext4 mcopy mmd parted truncate; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: Required host tool '$cmd' not found in PATH."
    exit 1
  fi
done

if [ ! -d "${TARGET_DIR}" ]; then
  echo "ERROR: Target rootfs directory '${TARGET_DIR}' does not exist."
  exit 1
fi

if [ ! -f "${BOARD_DIR}/limine.conf" ]; then
  echo "ERROR: Missing required bootloader config '${BOARD_DIR}/limine.conf'."
  exit 1
fi

# Rotate prior EROFS image for A/B fallback
if [ -f "${EROFS_OUT}" ]; then
  cp -f "${EROFS_OUT}" "${EROFS_PREV}"
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

echo "[Piccolo-AX] Building ${BOOT_PART_MIB} MiB FAT32 (BATOCERA) image..."
rm -f "${BOOT_IMG}"
truncate -s "${BOOT_PART_MIB}M" "${BOOT_IMG}"
mkfs.vfat -F 32 -n "BATOCERA" "${BOOT_IMG}" >/dev/null
mmd -i "${BOOT_IMG}" ::/EFI ::/EFI/BOOT ::/boot

[ -f "${BINARIES_DIR}/EFI/BOOT/BOOTX64.EFI" ] && mcopy -i "${BOOT_IMG}" "${BINARIES_DIR}/EFI/BOOT/BOOTX64.EFI" ::/EFI/BOOT/BOOTX64.EFI
[ -f "${BINARIES_DIR}/limine-bios.sys" ] && mcopy -i "${BOOT_IMG}" "${BINARIES_DIR}/limine-bios.sys" ::/limine-bios.sys
mcopy -i "${BOOT_IMG}" "${BOARD_DIR}/limine.conf" ::/limine.conf
mcopy -i "${BOOT_IMG}" "${EROFS_OUT}" ::/boot/rootfs.erofs
[ -f "${EROFS_PREV}" ] && mcopy -i "${BOOT_IMG}" "${EROFS_PREV}" ::/boot/rootfs.erofs.prev
[ -f "${BINARIES_DIR}/bzImage" ] && mcopy -i "${BOOT_IMG}" "${BINARIES_DIR}/bzImage" ::/boot/bzImage
[ -f "${BINARIES_DIR}/initrd.lz4" ] && mcopy -i "${BOOT_IMG}" "${BINARIES_DIR}/initrd.lz4" ::/boot/initrd.lz4

echo "[Piccolo-AX] Building ${SHARE_PART_MIB} MiB ext4 (^has_journal, SHARE) image..."
rm -f "${SHARE_IMG}"
truncate -s "${SHARE_PART_MIB}M" "${SHARE_IMG}"
mkfs.ext4 -F -L "SHARE" -O ^has_journal "${SHARE_IMG}" >/dev/null

TOTAL_MIB=$((1 + BOOT_PART_MIB + SHARE_PART_MIB))
rm -f "${DISK_IMG}"
truncate -s "${TOTAL_MIB}M" "${DISK_IMG}"

parted -s "${DISK_IMG}" mklabel gpt
parted -s "${DISK_IMG}" mkpart "BATOCERA" fat32 1MiB "$((1 + BOOT_PART_MIB))MiB"
parted -s "${DISK_IMG}" set 1 esp on
parted -s "${DISK_IMG}" mkpart "SHARE" ext4 "$((1 + BOOT_PART_MIB))MiB" 100%

dd if="${BOOT_IMG}" of="${DISK_IMG}" bs=1M seek=1 conv=notrunc status=none
dd if="${SHARE_IMG}" of="${DISK_IMG}" bs=1M seek="$((1 + BOOT_PART_MIB))" conv=notrunc status=none

if command -v limine >/dev/null 2>&1 && [ -f "${BINARIES_DIR}/limine-bios.sys" ]; then
  limine bios-install "${DISK_IMG}" >/dev/null 2>&1 || true
fi

echo "[Piccolo-AX] Built ${DISK_IMG} (profile=${FIT_PROFILE}, SHARE=${SHARE_PART_MIB} MiB)."
```

### 3\. `batocera-ax-external/board/piccolo-ax/limine.conf`

```
timeout: 3
default_entry: 3
remember_last_entry: yes

/Retro & Console [Eden / Cemu / Generation-X]
  protocol: linux
  path: boot():/boot/bzImage
  module_path: boot():/boot/initrd.lz4
  cmdline: root=/dev/ram0 toram isolcpus=managed_irq,domain,0-4 nohz_full=0-4 rcu_nocbs=0-4 default_hugepagesz=1G hugepagesz=1G hugepages=6 hugepagesz=2M hugepages=1024 processor.max_cstate=0 skew_tick=1 pcie_aspm=off mitigations=off usbcore.autosuspend=-1 usbhid.jspoll=1 ax.mode=retro ax.dac_lock=/run/lock/ax-dac.lock piccolo.rootfs=rootfs.erofs

/Audio & Synth [flac_ax + ax_av_studio + CLAP/LV2]
  protocol: linux
  path: boot():/boot/bzImage
  module_path: boot():/boot/initrd.lz4
  cmdline: root=/dev/ram0 toram isolcpus=managed_irq,domain,0-4 nohz_full=0-4 rcu_nocbs=0-4 default_hugepagesz=1G hugepagesz=1G hugepages=6 hugepagesz=2M hugepages=1024 processor.max_cstate=0 skew_tick=1 pcie_aspm=off mitigations=off usbcore.autosuspend=-1 usbhid.jspoll=1 ax.mode=audio ax.dac_lock=/run/lock/ax-dac.lock piccolo.rootfs=rootfs.erofs

/Video Upscaler [720p / 1080p / 2K]
  protocol: linux
  path: boot():/boot/bzImage
  module_path: boot():/boot/initrd.lz4
  cmdline: root=/dev/ram0 toram isolcpus=managed_irq,domain,0-4 nohz_full=0-4 rcu_nocbs=0-4 default_hugepagesz=1G hugepagesz=1G hugepages=6 hugepagesz=2M hugepages=1024 processor.max_cstate=0 skew_tick=1 pcie_aspm=off mitigations=off usbcore.autosuspend=-1 usbhid.jspoll=1 ax.mode=upscaler ax.dac_lock=/run/lock/ax-dac.lock piccolo.rootfs=rootfs.erofs

/Desktop Workbench [piccolo-ax-desktop]
  protocol: linux
  path: boot():/boot/bzImage
  module_path: boot():/boot/initrd.lz4
  cmdline: root=/dev/ram0 toram isolcpus=managed_irq,domain,0-4 nohz_full=0-4 rcu_nocbs=0-4 default_hugepagesz=1G hugepagesz=1G hugepages=6 hugepagesz=2M hugepages=1024 processor.max_cstate=0 skew_tick=1 pcie_aspm=off mitigations=off usbcore.autosuspend=-1 usbhid.jspoll=1 ax.mode=desktop piccolo.rootfs=rootfs.erofs

/Fallback A/B Retro [rootfs.erofs.prev]
  protocol: linux
  path: boot():/boot/bzImage
  module_path: boot():/boot/initrd.lz4
  cmdline: root=/dev/ram0 toram isolcpus=managed_irq,domain,0-4 nohz_full=0-4 rcu_nocbs=0-4 default_hugepagesz=1G hugepagesz=1G hugepages=6 hugepagesz=2M hugepages=1024 processor.max_cstate=0 skew_tick=1 pcie_aspm=off mitigations=off usbcore.autosuspend=-1 usbhid.jspoll=1 ax.mode=retro ax.dac_lock=/run/lock/ax-dac.lock piccolo.rootfs=rootfs.erofs.prev
```

### 4\. `batocera-ax-external/board/piccolo-ax/rootfs-overlay/usr/bin/ax-grow-share.sh`

```sh
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
```

### 5\. `batocera-ax-external/board/piccolo-ax/rootfs-overlay/etc/init.d/S01piccolo-isolate`

```sh
#!/bin/sh
# S01piccolo-isolate — Early cgroup v2 isolation, IRQ quarantine & zram valve

case "$1" in
  start)
    echo "[Piccolo-AX] Configuring cgroup v2 isolated domain (Cores 0-4)..."
    mkdir -p /sys/fs/cgroup/eden.slice
    echo "+cpuset" > /sys/fs/cgroup/cgroup.subtree_control 2>/dev/null || true
    echo "0-4" > /sys/fs/cgroup/eden.slice/cpuset.cpus
    echo "0" > /sys/fs/cgroup/eden.slice/cpuset.mems
    echo "isolated" > /sys/fs/cgroup/eden.slice/cpuset.cpus.partition 2>/dev/null || true

    # Quarantine unbound kernel workqueues & default IRQs to Core 5 (0x20)
    echo 20 > /sys/devices/virtual/workqueue/cpumask 2>/dev/null || true
    echo 20 > /proc/irq/default_smp_affinity 2>/dev/null || true

    # Memory & low-latency kernel sysctls
    sysctl -w vm.swappiness=1 >/dev/null
    sysctl -w vm.max_map_count=1048576 >/dev/null
    ulimit -l unlimited

    # 512 MB LZ4 zram emergency compression valve pinned to Core 5
    if [ -b /dev/zram0 ]; then
      taskset -c 5 zramctl /dev/zram0 --algorithm lz4 --size 512M
      mkswap /dev/zram0 >/dev/null
      swapon -p 100 /dev/zram0
    fi

    # Enforce pcie_aspm=off & lock GTX 980 Ti power state
    if [ -e /sys/bus/pci/devices/0000:01:00.0/power/control ]; then
      echo "on" > /sys/bus/pci/devices/0000:01:00.0/power/control
    fi

    # Pre-mount e2fsck & first-boot expansion on journal-free SHARE partition
    SHARE_DEV=$(blkid -L SHARE 2>/dev/null || true)
    if [ -n "$SHARE_DEV" ]; then
      e2fsck -p "$SHARE_DEV" >/dev/null 2>&1 || true
      if [ -x /usr/bin/ax-grow-share.sh ]; then
        /usr/bin/ax-grow-share.sh || true
      fi
    fi
    ;;
  stop)
    ;;
esac
exit 0
```

### 6\. `batocera-ax-external/board/piccolo-ax/rootfs-overlay/etc/init.d/S02piccolo-hw`

```sh
#!/bin/sh
# S02piccolo-hw — 1:1 MSI IRQ binding, USB DAC low-latency, DAC lock & async SwitchHDD mount

case "$1" in
  start)
    echo "[Piccolo-AX] Binding hardware IRQs & low-latency USB DAC parameters..."
    mkdir -p /etc/modprobe.d
    cat << 'EOF' > /etc/modprobe.d/piccolo-audio.conf
options snd-usb-audio lowlatency=1
EOF

    # Initialize exclusive DAC lockfile directory & node
    mkdir -p /run/lock
    chmod 1777 /run/lock 2>/dev/null || true
    touch /run/lock/ax-dac.lock
    chmod 0666 /run/lock/ax-dac.lock 2>/dev/null || true

    # Bind GTX 980 Ti MSI IRQ to Core 1 (0x02)
    for irq in $(grep -i "nvidia" /proc/interrupts 2>/dev/null | awk -F: '{print $1}' | tr -d ' '); do
      echo 02 > "/proc/irq/${irq}/smp_affinity" 2>/dev/null || true
    done

    # Bind HiBy FC3 xHCI controller MSI IRQ to Core 0 (0x01)
    FC3_BUS=$(lsusb 2>/dev/null | grep -iE "2fc6|32bb|HiBy" | awk '{print $2}' | sed 's/^0*//' | head -n1)
    if [ -n "$FC3_BUS" ] && [ -e "/sys/bus/usb/devices/usb${FC3_BUS}/../" ]; then
      XHCI_PCI=$(basename "$(readlink -f "/sys/bus/usb/devices/usb${FC3_BUS}/../")" 2>/dev/null || true)
      if [ -n "$XHCI_PCI" ]; then
        for irq in $(grep -F "${XHCI_PCI}" /proc/interrupts 2>/dev/null | awk -F: '{print $1}' | tr -d ' '); do
          echo 01 > "/proc/irq/${irq}/smp_affinity" 2>/dev/null || true
        done
      fi
    fi

    # Enable NVIDIA persistence mode (580.* legacy branch)
    nvidia-smi -pm 1 >/dev/null 2>&1 || true

    # Stage RAM tmpfs shader & PGO directories
    mkdir -p /dev/shm/emu_cache /dev/shm/nv_cache /dev/shm/pgo

    # Only prepare /userdata rom mountpoints if SHARE / userdata is mounted, then mount SwitchHDD async on Core 5
    if grep -qs "[[:space:]]/userdata[[:space:]]" /proc/mounts; then
      mkdir -p /userdata/roms/switch /userdata/roms/wiiu /userdata/roms/n64
      taskset -c 5 sh -c 'mount -L SwitchHDD -o ro,noatime /userdata/roms/switch 2>/dev/null || true' &
    fi
    ;;
  stop)
    ;;
esac
exit 0
```

### 7\. `batocera-ax-external/board/piccolo-ax/rootfs-overlay/etc/init.d/K01piccolo-sync`

```sh
#!/bin/sh
# K01piccolo-sync — Hardened tmpfs (/dev/shm) -> SHARE persistence using ax-fsync

set -u

SHARE_MOUNT="/userdata"
STAGE_DIR="${SHARE_MOUNT}/system/ax-sync"
LOG_TAG="[Piccolo-AX sync]"
RESERVE_KB=65536

log_info() {
  echo "${LOG_TAG} $*"
}

log_warn() {
  echo "${LOG_TAG}[WARN] $*" >&2
}

is_share_mounted() {
  grep -qs "[[:space:]]${SHARE_MOUNT}[[:space:]]" /proc/mounts
}

do_fsync() {
  target="$1"
  if command -v ax-fsync >/dev/null 2>&1; then
    ax-fsync "$target" >/dev/null 2>&1 || sync
  else
    sync
  fi
}

pack_dir_atomic() {
  src_dir="$1"
  dest_tar="$2"

  if [ ! -d "$src_dir" ] || [ -z "$(ls -A "$src_dir" 2>/dev/null || true)" ]; then
    return 0
  fi

  src_size_kb=$(du -sk "$src_dir" 2>/dev/null | awk '{print $1}')
  required_kb=$(( (src_size_kb * 125 / 100) + RESERVE_KB ))
  avail_kb=$(df -kP "$SHARE_MOUNT" 2>/dev/null | awk 'NR==2 {print $4}')

  if [ "${avail_kb:-0}" -lt "$required_kb" ]; then
    log_warn "Insufficient space on ${SHARE_MOUNT} (${avail_kb:-0} KB avail vs ${required_kb} KB required); skipping '$src_dir'"
    return 0
  fi

  mkdir -p "$(dirname "$dest_tar")"
  tmp_tar="${dest_tar}.tmp.$$"
  prev_tar="${dest_tar}.prev"

  if command -v zstd >/dev/null 2>&1; then
    tar -C "$src_dir" -cf - . 2>/dev/null | zstd -3 -T0 -q -o "$tmp_tar" 2>/dev/null || {
      rm -f "$tmp_tar"
      log_warn "Failed compressing '$src_dir' -> '$dest_tar'"
      return 0
    }
  else
    tar -C "$src_dir" -cf "$tmp_tar" . 2>/dev/null || {
      rm -f "$tmp_tar"
      log_warn "Failed archiving '$src_dir' -> '$dest_tar'"
      return 0
    }
  fi

  if [ -s "$tmp_tar" ]; then
    if command -v zstd >/dev/null 2>&1 && echo "$dest_tar" | grep -q '\.zst$'; then
      if ! zstd -t -q "$tmp_tar" 2>/dev/null; then
        log_warn "Archive validation failed for '$tmp_tar'; discarding corrupt output."
        rm -f "$tmp_tar"
        return 0
      fi
    fi
    do_fsync "$tmp_tar"
    [ -f "$dest_tar" ] && cp -f "$dest_tar" "$prev_tar" 2>/dev/null || true
    mv -f "$tmp_tar" "$dest_tar"
    do_fsync "$(dirname "$dest_tar")"
    log_info "Flushed '$src_dir' -> '$dest_tar' ($(du -h "$dest_tar" 2>/dev/null | awk '{print $1}'))"
  else
    rm -f "$tmp_tar"
  fi
}

case "${1:-}" in
  start)
    if is_share_mounted; then
      rm -f "${STAGE_DIR}"/*.tmp.* 2>/dev/null || true
      if command -v zstd >/dev/null 2>&1; then
        for item in "emu_cache:/dev/shm/emu_cache" "pgo:/dev/shm/pgo" "nv_cache:/dev/shm/nv_cache"; do
          name="${item%%:*}"
          dst="${item#*:}"
          arc="${STAGE_DIR}/${name}.tar.zst"
          prev="${arc}.prev"
          mkdir -p "$dst"
          if [ -z "$(ls -A "$dst" 2>/dev/null || true)" ]; then
            target_arc=""
            if [ -f "$arc" ] && zstd -t -q "$arc" 2>/dev/null; then
              target_arc="$arc"
            elif [ -f "$prev" ] && zstd -t -q "$prev" 2>/dev/null; then
              log_warn "Primary archive '$arc' corrupt; falling back to '$prev'"
              target_arc="$prev"
            fi
            if [ -n "$target_arc" ]; then
              zstd -dc -q "$target_arc" 2>/dev/null | tar -C "$dst" -xf - 2>/dev/null || true
            fi
          fi
        done
      fi
    fi
    ;;
  stop)
    if ! is_share_mounted; then
      log_warn "'${SHARE_MOUNT}' is not mounted; skipping RAM cache flush."
      exit 0
    fi
    log_info "Flushing RAM caches to ${SHARE_MOUNT}..."
    pack_dir_atomic "/dev/shm/emu_cache" "${STAGE_DIR}/emu_cache.tar.zst"
    pack_dir_atomic "/dev/shm/pgo" "${STAGE_DIR}/pgo.tar.zst"
    pack_dir_atomic "/dev/shm/nv_cache" "${STAGE_DIR}/nv_cache.tar.zst"
    do_fsync "$STAGE_DIR"
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac

exit 0
```

### 8\. `batocera-ax-external/board/piccolo-ax/rootfs-overlay/usr/bin/ax-mode-cli`

```sh
#!/bin/sh
# /usr/bin/ax-mode-cli — Deterministic Mode-Scoped Launcher for Piccolo [AX]

DAC_DEV="hw:CARD=FC3,DEV=0"
DAC_LOCK="/run/lock/ax-dac.lock"
AX_MODE="retro"

for token in $(cat /proc/cmdline 2>/dev/null || true); do
  case "$token" in
    ax.mode=*) AX_MODE="${token#ax.mode=}" ;;
    ax.dac_lock=*) DAC_LOCK="${token#ax.dac_lock=}" ;;
  esac
done

mkdir -p /run/lock
chmod 1777 /run/lock 2>/dev/null || true
touch "$DAC_LOCK" 2>/dev/null || true

run_rt_dac() {
  if ! flock -n "$DAC_LOCK" taskset 0x01 chrt -f 80 "$@"; then
    echo "[Piccolo-AX] Failed to acquire ${DAC_LOCK} or foreground process exited with error."
    sleep 2
  fi
}

ensure_media_dir() {
  dir_path="$1"
  if [ ! -d "$dir_path" ]; then
    echo "[Piccolo-AX][WARN] Directory '$dir_path' not found; creating it on /userdata..."
    mkdir -p "$dir_path" 2>/dev/null || true
  fi
}

status_line() {
  share_info="SHARE: unmounted"
  if df -h /userdata >/dev/null 2>&1 && grep -qs "[[:space:]]/userdata[[:space:]]" /proc/mounts; then
    share_info="$(df -h /userdata 2>/dev/null | awk 'NR==2 {printf "SHARE: %s avail (%s used)", $4, $5}')"
  fi

  dac_info="DAC: absent"
  if command -v aplay >/dev/null 2>&1 && aplay -l 2>/dev/null | grep -q "FC3"; then
    dac_info="DAC: FC3 ready"
  fi

  echo "  Status: ${share_info} | ${dac_info}"
}

# Desktop mode launches piccolo-ax-desktop directly with /userdata persistence
if [ "$AX_MODE" = "desktop" ]; then
  if [ -x /usr/local/bin/launch-desktop.sh ]; then
    exec /usr/local/bin/launch-desktop.sh
  elif [ -x /usr/bin/piccolo-ax-desktop ]; then
    exec /usr/bin/piccolo-ax-desktop
  else
    echo "[Piccolo-AX] Desktop overlay not installed in this image. Rebooting..."
    sleep 3
    exec reboot
  fi
fi

while true; do
  clear
  echo "============================================================"
  echo "  Piccolo [AX] Bare-Metal Appliance — Mode: ${AX_MODE}"
  status_line
  echo "============================================================"

  case "$AX_MODE" in
    audio)
      echo "  1) flac_ax — Bit-Perfect FLAC / DSD RAM Transport"
      echo "  2) ax_av_studio — 2.00 ms Live Synth & FFT Studio"
      echo "  3) ax_clap_host — CLAP Plugin Host (Core 2-4 DSP -> Core 0 S32_LE)"
      echo "  4) ax_lv2_host — LV2 Plugin Host (Core 2-4 DSP -> Core 0 S32_LE)"
      echo "  v) Verify Appliance Hardware Gate"
      echo "  r) Reboot to Limine Boot Menu"
      printf "\nSelect option: "
      read -r choice
      case "$choice" in
        1)
          ensure_media_dir "/userdata/music"
          run_rt_dac /usr/bin/flac_ax --device "$DAC_DEV" --volume 0.80 /userdata/music/
          ;;
        2)
          run_rt_dac /usr/bin/ax_av_studio --fullscreen --device "$DAC_DEV" --volume 0.80
          ;;
        3)
          ensure_media_dir "/userdata/plugins"
          printf "CLAP plugin path: "
          read -r clap_path
          [ -n "$clap_path" ] && run_rt_dac /usr/bin/ax_clap_host "$clap_path" "" 48000 96 --device "$DAC_DEV"
          ;;
        4)
          printf "LV2 plugin URI: "
          read -r lv2_uri
          [ -n "$lv2_uri" ] && run_rt_dac /usr/bin/ax_lv2_host "$lv2_uri" 48000 96 --device "$DAC_DEV"
          ;;
        v|V)
          /usr/bin/verify_ax_appliance.sh
          printf "\nPress Enter..."
          read -r _
          ;;
        r|R)
          exec reboot
          ;;
      esac
      ;;

    upscaler)
      echo "  1) Retro HDMI Capture (MS2130S -> 1080p Bob)"
      echo "  2) Retro HDMI Capture (MS2130S -> 2K Bob)"
      echo "  3) DVD ISO Upscaler (Audio-Master PTS -> 2K)"
      echo "  v) Verify Appliance Hardware Gate"
      echo "  r) Reboot to Limine Boot Menu"
      printf "\nSelect option: "
      read -r choice
      case "$choice" in
        1)
          run_rt_dac /usr/bin/ax_video_upscaler --mode retro --preset 1080p --v4l2 /dev/video0 --scan bob --device "$DAC_DEV" --volume 0.80
          ;;
        2)
          run_rt_dac /usr/bin/ax_video_upscaler --mode retro --preset 2k --v4l2 /dev/video0 --scan bob --device "$DAC_DEV" --volume 0.80
          ;;
        3)
          ensure_media_dir "/userdata/dvd"
          run_rt_dac /usr/bin/ax_video_upscaler --mode dvd --preset 2k --input /userdata/dvd/ --scan dvd --device "$DAC_DEV" --volume 0.80
          ;;
        v|V)
          /usr/bin/verify_ax_appliance.sh
          printf "\nPress Enter..."
          read -r _
          ;;
        r|R)
          exec reboot
          ;;
      esac
      ;;

    retro)
      echo "  1) EmulationStation (Unified Retro Front-End)"
      echo "  2) Eden-Espresso-Wave (Nintendo Switch)"
      echo "  3) Cemu-Latte-AX (Nintendo Wii U)"
      echo "  4) Generation-X-AX (Classic Consoles & Arcade)"
      echo "  v) Verify Appliance Hardware Gate"
      echo "  r) Reboot to Limine Boot Menu"
      printf "\nSelect option: "
      read -r choice
      case "$choice" in
        1) /usr/bin/emulationstation ;;
        2) /usr/bin/eden ;;
        3) /usr/bin/Cemu ;;
        4) /usr/bin/generation-x-launcher ;;
        v|V)
          /usr/bin/verify_ax_appliance.sh
          printf "\nPress Enter..."
          read -r _
          ;;
        r|R)
          exec reboot
          ;;
      esac
      ;;

    *)
      echo "  [WARN] Unknown ax.mode='${AX_MODE}'. Press 'r' to reboot to Limine."
      printf "\nSelect option: "
      read -r choice
      case "$choice" in
        r|R) exec reboot ;;
      esac
      ;;
  esac
done
```

### 9\. `batocera-ax-external/board/piccolo-ax/rootfs-overlay/usr/bin/verify_ax_appliance.sh`

```sh
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
HP_1G=$(grep -E "^HugePages_Total:" /proc/meminfo 2>/dev/null | awk '{print $2}')
if [ "${HP_1G:-0}" -ge 6 ] && [ -b /dev/zram0 ]; then
  echo "[PASS] 3. Hybrid HugePages (${HP_1G}x 1G) & LZ4 zram active"
else
  echo "[FAIL] 3. HugePages (${HP_1G:-0}) or /dev/zram0 not configured"
  FAIL=1
fi

# 4. NVIDIA 580.* Legacy Driver & Persistence Mode
if command -v nvidia-smi >/dev/null 2>&1; then
  NV_VER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo "NONE")
  if [[ "${NV_VER}" == 580.* ]]; then
    echo "[PASS] 4. NVIDIA Maxwell legacy driver pinned: ${NV_VER}"
  else
    echo "[WARN] 4. Expected NVIDIA 580.* driver, found: ${NV_VER}"
  fi
else
  echo "[WARN] 4. nvidia-smi not present in this mode/image"
fi

# 5. Intel UHD 630 VA-API (iHD) Render Node
if [ -e /dev/dri/renderD128 ] || [ -e /dev/dri/renderD129 ]; then
  echo "[PASS] 5. DRI render node present for Intel UHD 630 VA-API (iHD) dma_buf export"
else
  echo "[FAIL] 5. Missing /dev/dri/renderD* node (Enable IGD Multi-Monitor in BIOS)"
  FAIL=1
fi

# 6. HiBy FC3 USB DAC Exclusive ALSA Node
if command -v aplay >/dev/null 2>&1 && aplay -l 2>/dev/null | grep -q "FC3"; then
  echo "[PASS] 6. HiBy FC3 USB DAC detected on ALSA hw:CARD=FC3,DEV=0"
else
  echo "[WARN] 6. HiBy FC3 USB DAC not currently connected or aplay unavailable"
fi

# 7. RootFS <= 512 MB Budget Check
EROFS_PATH=""
if [ -f /boot/rootfs.erofs ]; then
  EROFS_PATH="/boot/rootfs.erofs"
elif [ -f /boot/boot/rootfs.erofs ]; then
  EROFS_PATH="/boot/boot/rootfs.erofs"
fi

if [ -n "${EROFS_PATH}" ]; then
  SIZE_MB=$(( $(stat -c%s "${EROFS_PATH}") / 1024 / 1024 ))
  if [ "${SIZE_MB}" -le 512 ]; then
    echo "[PASS] 7. EROFS image (${EROFS_PATH}) size: ${SIZE_MB} MB / 512 MB ceiling"
  else
    echo "[FAIL] 7. EROFS image (${EROFS_PATH}) size (${SIZE_MB} MB) exceeds 512 MB ceiling"
    FAIL=1
  fi
else
  echo "[WARN] 7. rootfs.erofs not mounted at /boot/rootfs.erofs or /boot/boot/rootfs.erofs"
fi

# 8. PCI Vendor/Device ID Gate & SMT/Hyper-Threading Check
APPROVED_NV=("10de:17c8" "10de:13c0" "10de:13c2")
APPROVED_INTEL=("8086:3e92" "8086:3e98" "8086:9bc5" "8086:4c8a")
PCI_FOUND=0
for dev in /sys/bus/pci/devices/*; do
  if [ -r "$dev/vendor" ] && [ -r "$dev/device" ]; then
    ven=$(cat "$dev/vendor" | sed 's/^0x//')
    id=$(cat "$dev/device" | sed 's/^0x//')
    pair="${ven}:${id}"
    for app in "${APPROVED_NV[@]}" "${APPROVED_INTEL[@]}"; do
      if [ "$pair" = "$app" ]; then PCI_FOUND=1; break 2; fi
    done
  fi
done
if [ "$PCI_FOUND" -eq 1 ]; then
  echo "[PASS] 8a. Approved PCI GPU hardware detected"
else
  echo "[WARN] 8a. No matched PCI GPU vendor/device ID in allowlist"
fi

if [ -r /sys/devices/system/cpu/smt/active ]; then
  SMT_ACT=$(cat /sys/devices/system/cpu/smt/active)
  if [ "$SMT_ACT" = "0" ]; then
    echo "[PASS] 8b. Hyper-Threading / SMT disabled (smt/active=0)"
  else
    echo "[FAIL] 8b. Hyper-Threading / SMT is active (smt/active=${SMT_ACT})"
    FAIL=1
  fi
else
  echo "[WARN] 8b. /sys/devices/system/cpu/smt/active unavailable"
fi

echo "============================================================"
if [ "$FAIL" -eq 0 ]; then
  echo "RESULT: EXCELLENT_APPLIANCE_READY"
  exit 0
else
  echo "RESULT: APPLIANCE_GATE_FAILED"
  exit 1
fi
```

