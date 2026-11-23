# 🛠️ Eden Piccolo [AX] — Master Implementation Plan & Workpackage (v0.5)

**End-to-End Engineering Roadmap, Batocera `BR2_EXTERNAL` Scope Matrix, Prerequisite Toolchain & Mirror Lock, Prototyping Accelerators, and Sprint 0–5 Execution Plan**

* **Target Architecture:** `PICCOLO_AX_SPEC.md` (`v0.6`) & `ARCHITECTURE_SPEC.md` (`MASTER v1.35`)
* **Target Hardware Profile:** Intel Core i5-9600K (`6C/6T`, Zero SMT, `x49` / `4.9 GHz` Core 0, `x48` / `4.8 GHz` Cores 1–5, Ring `x45` / `4.5 GHz`) · 32 GB Dual-Channel DDR4-3600 · NVIDIA GeForce GTX 980 Ti (`6 GB` GDDR5, Maxwell GM200) · Intel UHD Graphics 630 iGPU (`0x8086`) · HiBy FC3 USB DAC (ESS Sabre ES9281AC Pro)
* **Boot Medium:** Samsung FIT Plus 64 GB USB 3.1 Gen 1 (`MUF-64AB/APC`) — Hybrid `4.0 GB FAT32 BATOCERA` + `~55.6 GB ^has_journal ext4 SHARE` (`< 512 MB` `EROFS` `toram` OS)

---

## 📑 Table of Contents

* [Chapter 1: Batocera Linux Scope Matrix (`IN` vs. `OUT` + `< 512 MB` Size Guard)](#-chapter-1-batocera-linux-scope-matrix-in-vs-out--512-mb-size-guard)
* [Chapter 2: Prerequisite Toolchain & Reproducible Git/Binary Mirrors (`dl/` Lock)](#-chapter-2-prerequisite-toolchain--reproducible-gitbinary-mirrors-dl-lock)
* [Chapter 3: Reusable Open-Source Prototyping Assets (`Sprint 0–3` Accelerators)](#-chapter-3-reusable-open-source-prototyping-assets-sprint-03-accelerators)
* [Chapter 4: Milestone- & Gate-Driven Sprint Progression (`Sprint 0` Gate → `Sprint 5` Production)](#-chapter-4-milestone--gate-driven-sprint-progression-sprint-0-gate--sprint-5-production)
* [Chapter 5: Step-by-Step Buildroot & C++20 Integration Checklists (`Stages 1–5`)](#-chapter-5-step-by-step-buildroot--c20-integration-checklists-stages-15)

---

## 🐧 Chapter 1: Batocera Linux Scope Matrix (`IN` vs. `OUT` + `< 512 MB` Size Guard)

To compress Batocera Linux from a standard `1.5–2.5 GB` multi-system distribution into an immutable, RAM-resident **`< 512 MB` EROFS (`lz4hc,9`)** multi-console `[AX]` appliance (`Eden` Switch, `Cemu` Wii U, `RMG` N64), every component is classified below[cite: 13].

### ✅ 1.1 What Is IN (Retained & Hardened Batocera Components)

1. **Buildroot Out-of-Tree Overlay Infrastructure (`BR2_EXTERNAL`):**
   * Batocera's `BR2_EXTERNAL` makefile hook (`external.desc`, `external.mk`, `Config.in`) plus `board/piccolo-ax/post-build.sh` and `post-image.sh` hooks to package `eden-ax`, `cemu-latte-ax`, and `rmg-ax` (compiled with Clang 23+ ThinLTO/PGO) alongside a GCC-compiled base OS.
2. **UEFI Bootloader & GRUB Kernel Command-Line Layer (with A/B Rollback):**
   * Minimal UEFI `grubx64.efi` boot chain from the `4.0 GB` FAT32 `BATOCERA` partition (with secondary A/B fallback entry booting `rootfs.erofs.prev`), configured with static kernel parameters:

```text
isolcpus=managed_irq,domain,0-4 nohz_full=0-4 rcu_nocbs=0-4 default_hugepagesz=1G hugepagesz=1G hugepages=6 hugepagesz=2M hugepages=1024 processor.max_cstate=0 skew_tick=1 pcie_aspm=off mitigations=off usbcore.autosuspend=-1 usbhid.jspoll=1
```

3. **Custom `initrd` `toram` Hook & BusyBox SysVinit Core (`/etc/init.d/`):**
   * Early `initrd` sequential block copy (`dd if=/boot_root/boot/rootfs.erofs of=/dev/shm/rootfs.erofs bs=4M`, falling back to `rootfs.erofs.prev` on checksum/mount failure) loading the `< 512 MB` EROFS image into `/dev/shm` (`~0.75s` on Samsung FIT Plus) before `switch_root`.
   * Lean BusyBox SysVinit orchestrating:
     * **`S01piccolo-isolate`:** Pure `cgroup v2` unified hierarchy, `/sys/devices/virtual/workqueue/cpumask=0x20`, `/proc/irq/default_smp_affinity=0x20`, `pcie_aspm=off` + `power/control=on` on `0000:01:00.0`, `512 MB` LZ4 `zram` (`vm.swappiness=1`), and `e2fsck -p` pre-mount check on `^has_journal` `SHARE`.
     * **`S02piccolo-hw`:** Static module loads (`nvidia`, `nvidia-drm`, `i915`, `snd-usb-audio nrpacks=1 lowlatency=1`), Core 0 (`0x01`, `itr=0`) MSI IRQ pinning for the HiBy FC3 xHCI controller, static `/etc/X11/xorg.conf`, and asynchronous Core 5 background mount (`taskset -c 5 mount -L SwitchHDD -o ro,noatime /userdata/roms/switch &`) so 7200 RPM platter spin-up never delays cold boot.
     * **`K01piccolo-sync`:** Atomic `zstd -3` `.tar.zst.tmp` → `sync` → `mv -f` cache flush on shutdown/reboot.
4. **EmulationStation Front-End (Controller-Only Launcher UI):**
   * Retained solely as a minimalist 10-foot console game selector (`es_systems_*.cfg` routed via `axGenerator.py`) with minimal themes and **frozen via `SIGSTOP` + quarantined to Core 5 (`0x20`)** the instant a Switch title launches (reclaiming `~200 MB` VRAM and `~250 MB` RAM).
5. **Bare Uncomposited X.Org Server (`xorg-server`):**
   * Minimal X11 server with static PCIe BusID bindings (`BusID "PCI:1:0:0"` GTX 980 Ti, `BusID "PCI:0:2:0"` Intel UHD 630), `Option "AllowFlipping" "True"`, and `Option "TripleBuffer" "False"` to host `lsfg-vk 2.0.0+` WSI swapchain hooks cleanly without compositor latency.
6. **Core Audio, GPU, Controller Exit Hook & Storage Plumbing:**
   * **`alsa-lib` & `alsa-utils`:** Direct exclusive hardware PCM access (`hw:CARD=FC3,DEV=0`, `S32_LE`, `48 kHz`, `96 frames × 2 periods`).
   * **Hard-Pinned NVIDIA `580.*` Legacy Vulkan/GLX Stack:** Retained strictly for Maxwell GM200 Vulkan 1.3 (`libGLX_nvidia.so*`, `libnvidia-glcore.so*`, `nvidia_icd.json`).
   * **Intel `intel-media-driver` (`iHD`) + `libva`:** Retained strictly for UHD 630 hardware H.264/HEVC/VP8/VP9 decode into `DRM_FORMAT_MOD_LINEAR` `dma_buf` FDs.
   * **Core CLI, Python 3 & Controller Exit Combo:** Minimal Python 3 interpreter (`axGenerator.py`) + `vmtouch`, `zstd`, `e2fsprogs`, `util-linux` (`taskset`, `chrt`, `zramctl`), plus a built-in **`Select/Minus + Start/Plus` (1.5s hold)** controller exit hook on Core 5 `/dev/hidraw*` so titles exit cleanly back to EmulationStation without a keyboard or window manager.

### ❌ 1.2 What Is OUT (Excised Batocera Subsystems & Bloat)

| Category | Stripped Batocera Components (`OUT`) | Engineering & Determinism Rationale |
| :--- | :--- | :--- |
| **Non-[AX] Emulators & Cores** | All RetroArch cores, Dolphin, PCSX2, RPCS3, DuckStation, PPSSPP, MAME, Flycast, ScummVM, Ports, and BIOS packs | Removes `> 1.2 GB` of rootfs bloat; retains only `[AX]` engines (`Eden` Switch, `Cemu` Wii U, `RMG` N64). |
| **User-Space Audio Daemons** | **PipeWire**, **PulseAudio**, `wireplumber`, `jack2`, `alsa-plugins` software mixers | Prevents background resampling threads and open file locks on `hw:CARD=FC3,DEV=0`, enabling `SCHED_FIFO 99` exclusive ALSA. |
| **Window Managers & Compositors** | **Openbox**, `picom`, `weston`, `sway`, Wayland compositor shells, desktop splash/video screensavers | Eliminates extra VBLANK presentation queues, swapchain redirection, and VBLANK polling jitter (`vk_vram_shield.hpp`). |
| **NVIDIA Compute & AI Blobs** | `libcuda.so*`, `libnvidia-ptxjitcompiler.so*`, `libnvidia-nvvm.so*`, `libnvidia-opencl.so*`, `libnvidia-optix.so*`, `libnvidia-encode.so*`, `libnvidia-fbc.so*` | Saves **`~200+ MB`** in rootfs; Maxwell `GM200` Vulkan rendering and UHD 630 VA-API decode never touch CUDA/OptiX/NVENC. |
| **Mesa Software & Non-Intel Drivers** | `llvmpipe`, `lavapipe`, `radeonsi`, `radv`, `nouveau`, `nvk`, `panfrost`, `zink`, and **`~80 MB` of target LLVM runtime** | Saves **`~100+ MB`**; prevents software rasteriser fallback and avoids Nouveau/NVK non-GSP Maxwell clock-reclocking stalls. |
| **Background Network & Discovery Daemons** | `avahi-daemon` (mDNS), `ntpd` / `chrony`, `wpa_supplicant` / `connman` / `NetworkManager`, `samba` / `nfs-utils`, `upnp` / `dlna` | Eliminates periodic network timer interrupts, DHCP/mDNS broadcasts, and unbound `kworker` wakeups on Cores `0–4`. |
| **Bluetooth & Wireless Input Daemons** | `bluetoothd` (`bluez`), `hid-nintendo` DKMS overrides (unless required), `batocera-evmapy` hotkey polling daemon | Eliminates `2.4 GHz` Bluetooth radio polling jitter and background `evmapy` Python/evdev daemons in favour of Core 5 `/dev/hidraw*` (`1000 Hz`). |
| **Dynamic Hardware Discovery & Overlay Bloat** | Heavy `udev` rule sweeps (`batocera-nvidia` runtime xorg generators), `batocera-save-overlay`, `rngd`, `smartmontools`, `udisks2` | Eliminates multi-second boot delays and runtime storage/PCIe polling spikes via static PCIe BusID bindings. |
| **Media, Scraping & Web Services** | `kodi`, built-in EmulationStation metadata/video scrapers, RetroAchievements network polling, web-manager HTTP API (`batocera-web-api`) | Prevents background HTTP/SQLite/disk writes and eliminates background thread contention during gameplay. |

### 🛡️ 1.3 Automated `< 512 MB` Image Budget Guard (`post-image.sh`)

To prevent feature additions in Sprints 3–5 from silently breaching the `toram` memory/boot envelope, `board/piccolo-ax/post-image.sh` enforces a hard compile-time size assertion[cite: 13]:

```bash
MAX_EROFS_KB=524288 # 512 MiB ceiling
ACTUAL_KB=$(du -k "${BINARIES_DIR}/rootfs.erofs" | cut -f1)
if [ "${ACTUAL_KB}" -gt "${MAX_EROFS_KB}" ]; then
    echo "ERROR: rootfs.erofs (${ACTUAL_KB} KB) exceeds 512 MB toram budget!"
    du -ah "${TARGET_DIR}" | sort -rh | head -n 15
    exit 1
fi
```

---

## 🧰 Chapter 2: Prerequisite Toolchain & Reproducible Git/Binary Mirrors (`dl/` Lock)

### 2.1 Build-Host Prerequisite Tools & Software (`x86_64` Linux Host)

Requires an `x86_64` Linux build machine (Ubuntu 24.04 LTS / Debian 12 / Arch Linux, or WSL2 Ubuntu on an `ext4` volume) with `>= 16 GB RAM` and `60 GB` free disk space[cite: 13]:

* **Core Buildroot & Kernel Compilation Dependencies:** `build-essential`, `gcc`, `g++`, `make`, `cmake` (`>= 3.28`), `ninja-build`, `binutils`, `patch`, `diffutils`, `cpio`, `unzip`, `rsync`, `bc`, `bison`, `flex`, `libelf-dev`, `libssl-dev`, `libncurses-dev`, `perl`, `gawk`, `file`, `wget`, `curl`, `git`
* **Standalone Clang 23+ & PGO Toolchain (Strictly for `eden` Binary):** `clang-23`, `clang++-23`, `lld-23`, `llvm-profdata-23`, `llvm-ar-23`, `llvm-ranlib-23`
* **Filesystem, Image Packaging & Flashing Tools:** `erofs-utils` (`mkfs.erofs` with `lz4hc`), `squashfs-tools`, `zstd` (`>= 1.5`), `dosfstools` (`mkfs.vfat`), `e2fsprogs` (`mkfs.ext4`, `e2fsck`), `parted` / `gdisk`, `mtools`

### 2.2 Target Appliance Software Stack (Baked into `batocera-ax-external/`)

| Subsystem | Package / Component | Pin / Version Constraint | Purpose in Eden Piccolo [AX] |
| :--- | :--- | :--- | :--- |
| **OS Base** | `batocera.linux` (`x86_64`) | Latest stable tag (`BR2_EXTERNAL`) | Minimal console init, EmulationStation front-end, UEFI bootloader |
| **Kernel** | Mainline Linux `6.12.x` LTS | `CONFIG_PREEMPT_RT=y`, `CONFIG_DRM_TTM_HELPER=y` | Mainline `x86_64` real-time kernel with `1G`/`2M` HugeTLB & `nohz_full` |
| **dGPU Driver** | NVIDIA Proprietary Driver | **Hard-pinned `580.*` legacy** (e.g., `580.126.09`) | Final official Maxwell (`GM200`) Vulkan 1.3 driver (`590+` drops Maxwell) |
| **iGPU Video** | `intel-media-driver` (`iHD`) + `libva` | Latest `24.x` / `25.x` | Intel UHD 630 (`0x8086`) hardware H.264/HEVC/VP8/VP9 decode → `dma_buf` |
| **Frame Gen** | `lsfg-vk` + `lsfg-vk-cli` | **`2.0.0+`** (Vulkan 1.2 bindless, FP32 mode) | Implicit Vulkan frame-generation layer (requires user-supplied `Lossless.dll`) |
| **Audio** | `alsa-lib` + `alsa-utils` (`aplay`) | PipeWire & PulseAudio **stripped** | Direct `hw:CARD=FC3,DEV=0` `S32_LE` `48 kHz` (`96 frames × 2 periods` / `2.00 ms` ring) |
| **Asset Pinning** | `vmtouch` | `>= 1.3.1` (`MAP_POPULATE` `-dql`) | Bulk-pins `17.5 GB` filtered `.nsp`/`.xci` archives into DDR4-3600 RAM |
| **Memory Guard** | `zram-init` / `util-linux` (`zramctl`) | `512 MB` LZ4 `zram` (`swappiness=1`) | Zero-USB-I/O emergency compression valve protecting the `5.0 GB` host floor |
| **Display** | Minimal `xorg-server` + `xf86-video-intel` | No Openbox / No compositor | Bare uncomposited X11 page-flipping (`AllowFlipping=True`, `TripleBuffer=False`)

### 2.3 Primary Git Repositories & Offline Binary Archives (`dl/` Lock)

Mirror these repositories locally so upstream deprecations never break your build[cite: 13]:

1. **Eden Espresso Wave [AX] & Piccolo Spec:** `https://github.com/galaxywarriordad/Eden-Espresso-Wave-AX.git` (`PICCOLO_AX_SPEC.md` `v0.6` & `ARCHITECTURE_SPEC.md` `MASTER v1.35`)
2. **Eden4CoffeeLake / Eden Emulator Source:** `https://git.eden-emu.dev/galaxywarriordad/Eden4CoffeeLake.git` & `https://github.com/eden-emulator/Eden.git` (verify **PR #3817** `HeapTracker` removal, **#4819**, **#4210**, **#4664**, **#2**, **#32**)
3. **Citron Upstream Reference (Maxwell Safety Backports):** `https://git.citron-emu.org/Citron/Emulator.git` (**PR #4688**, **#449**, **#383**, **#448**, **#447**, **#385**, **#4966**, **#5102**, **#5311**)
4. **Batocera Linux Buildroot Tree:** `https://github.com/batocera-linux/batocera.linux.git`
5. **Linux `6.12.x` LTS Kernel Archive:** `https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git` (`linux-6.12.y` branch — native `PREEMPT_RT` merged)
6. **`lsfg-vk` (`v2.0.0+`):** `https://github.com/PancakeTAS/lsfg-vk.git` (Vulkan 1.2 bindless & FP32 shader mode)
7. **`vmtouch`:** `https://github.com/hoytech/vmtouch.git` (`-dql` `MAP_POPULATE` support)
8. **Intel Media Driver (`iHD`):** `https://github.com/intel/media-driver.git`
9. **Vulkan Memory Allocator (`VMA`):** `https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator.git` (`VMA_ALLOCATOR_CREATE_EXT_MEMORY_BUDGET_BIT`)
10. **Xbyak JIT Assembler:** `https://github.com/herumi/xbyak.git`
11. **Offline Binary Cache (`dl/`):**
    * `NVIDIA-Linux-x86_64-580.126.09.run` (from `https://download.nvidia.com/XFree86/Linux-x86_64/`) — **mandatory offline mirror** (final Maxwell driver series).
    * `Lossless.dll` (user-supplied from licensed Steam *Lossless Scaling* copy onto `/userdata/system/lsfg/Lossless.dll`).

---

## ⚡ Chapter 3: Reusable Open-Source Prototyping Assets (`Sprint 0–3` Accelerators)

Rather than writing low-level kernel/Vulkan boilerplate from scratch, adapt these verified open-source assets during prototyping:

| Sprint Task | Existing Git Asset to Reuse | Adaptation Strategy |
| :--- | :--- | :--- |
| **Sprint 0 `NV12 dma_buf` Probe** | `nuketownada/egl-dmabuf-probe` + `mpv` (`video/out/hwdec/hwdec_vaapi.c` & `gpu/hwdec_vulkan.c`) | Uses `VkImageDrmFormatModifierListCreateInfoEXT` (bypassing NVIDIA's rejection of `ExplicitCreateInfoEXT`) for planar `R8_UNORM` + `R8G8_UNORM` `NV12` import. |
| **Sprint 0 `nohz_full` Audit** | `Chester-Gillon/f041abe27f44027a5c513aff1154b205` (`LOC` timer interrupt delta parser) | Drop `/proc/interrupts` `LOC` delta check straight into `verify_ax_appliance.sh` to prove zero ticks on Cores `0–4`. |
| **Sprint 1 `BR2_EXTERNAL` Tree** | `Hancock33/batocera.piboy` + `batocera-initramfs` (`boot/init`) | Reuse `external.desc` / `Config.in` overlay skeleton and inject a 6-line `dd bs=4M` `toram` copy before `switch_root`. |
| **Sprint 2 `1G` HugeTLB Arena** | `evanj/hugepagedemo` (`MAP_HUGE_1GB`) | Wrap `mmap(..., MAP_HUGETLB \| MAP_HUGE_1GB)` + `mlockall()` with `MAP_HUGE_2MB` fallback in `ax_platform_shim.hpp`. |
| **Sprint 3 Maxwell Guards** | `Citron` PRs `#4688, #449, #383, #448, #385` + `Eden` `#3817` | Cherry-pick/port existing diff hunks for `maxPushDescriptors`, UBO page contiguity, and `HeapTracker` leak removal. |

---

## 🗺️ Chapter 4: Milestone- & Gate-Driven Sprint Progression (`Sprint 0` Gate → `Sprint 5` Production)

All OS build phases and C++20 integration stages are sequenced into **six milestone-driven sprints** governed strictly by technical exit gates rather than fixed calendar estimates. **Sprint 0 executes on a temporary Ubuntu 24.04 / Arch Live USB** installed with `linux-6.12-rt` + `NVIDIA 580.126.09` so hardware unknowns are retired on bare metal before compiling Buildroot[cite: 13].

### 4.1 Sequential Dependency Pipeline

1. **Sprint 0 (`Gate` — Hardware & RT Smoke Tests):** Live USB bench verifying `Linux 6.12-rt` + `NVIDIA 580.*` (`P0`), `rdmsr 0xc8f` CAT probe, `NV12 dma_buf` import, and zero-xrun `HiBy FC3` ALSA output.
2. **Sprint 1 (`MVP v0.6` — First Bootable USB Appliance):** `< 512 MB` `EROFS` `toram` boot from Samsung FIT Plus, `BR2_EXTERNAL` pruning, `BC3`, `2M` HugePages, `SIGSTOP` EmulationStation, and 30/60 FPS gameplay.
3. **Sprint 2 (`v0.7` — Core 0 Audio, 1G HugePages & `vmtouch`):** `6 GB (1G) + 2 GB (2M)` HugePages, `17.5 GB` `vmtouch -dql` asset pinning, fused Core 0 `2.00 ms` ALSA loop, Z390 Ring `x45`, and `-1.5 ms` VBLANK input latch.
4. **Sprint 3 (`v0.8` — `5.35 GB` VRAM Shield, `BC7/BC6H` & Maxwell Parity):** `VK_EXT_memory_budget` shield + `< 64 KB` reaper, Option C lossless `RGBA8` (`< 4.5 GB`), `GM200` `FP16 → FP32` promotion & compute ASTC, and `MASTER v1.34` guards.
5. **Sprint 4 (`v0.9` — Cross-GPU `DMA-BUF` & `lsfg-vk` Frame Gen):** Intel UHD 630 `iHD` VA-API → GTX 980 Ti `NV12` zero-copy bridge, `VK_QUEUE_TRANSFER_BIT` async DMA, `256 MB BAR1` WC pool, and `lsfg-vk 2.0.0+` (FP32).
6. **Sprint 5 (`v1.0 → v2.00` — PGO Bake, Telemetry & Next-Gen R&D):** Closed-loop `clock_nanosleep` governor, native `GM200` `SHFL` subgroup reductions, `/dev/ttyACM0` telemetry, two-stage PGO bake (`STAGE=2`), and Phase 6 VME/RP2040 R&D.

### 4.2 Sprint-by-Sprint Scope & Mandatory Exit Gates

| Sprint | Target Version | Bootable Medium | Incremental Scope Added | Mandatory Exit Gate (Definition of Done) |
| :--- | :--- | :--- | :--- | :--- |
| **Sprint 0** | Gate | Live USB Bench | `Linux 6.12-rt` + `NVIDIA 580.*` boot, `rdmsr 0xc8f` Intel CAT check (`_MM_HINT_NTA` fallback), xHCI bus split check, `S32_LE` ALSA probe, standalone `NV12 dma_buf` Vulkan test. | `6.12-rt` + `NVIDIA 580.*` (`P0`) + `rdmsr 0xc8f` CAT check + `NV12 dma_buf` (`ModifierListCreateInfoEXT`) + `HiBy FC3` (`0` xruns) verified on bare metal. |
| **Sprint 1** | **MVP (`v0.6`)** | **Samsung FIT Plus** | `BR2_EXTERNAL` pruning, `< 512 MB` `EROFS` `toram` (`mitigations=off`, A/B `.prev`), `S01`/`S02`/`K01`, Clang 23+ `eden` build, bare Xorg, `SIGSTOP` ES, `BC3`, `2M` HugePages. | Cold-booting `< 512 MB` `toram` EROFS USB appliance running Switch titles at 30/60 FPS (`BC3`, controller exit combo, `0` xruns, atomic `.tar.zst` sync). |
| **Sprint 2** | `v0.7` | Samsung FIT Plus | `6 GB (1G) + 2 GB (2M)` HugePages + `5.0 GB` safety floor, `17.5 GB` `vmtouch -dql` container filter, fused Core 0 `2.00 ms` ALSA, Z390 Ring `x45`, `-1.5 ms` VBLANK input latch. | Zero HDD seek stalls (`17.5 GB vmtouch` active), `1G` HugeTLB mapped, `0` `LOC` ticks on Core 0, `2.00 ms` (`96-frame`) audio with `0` xruns. |
| **Sprint 3** | `v0.8` | Samsung FIT Plus | `5.50 GB` `VK_EXT_memory_budget` shield + `< 64 KB` reaper, Option C lossless `RGBA8` (`< 4.5 GB`) + `BC7`/`BC6H`, `GM200` `FP16 → FP32` promotion & compute ASTC, `MASTER v1.34` guards. | Lossless `RGBA8` / `BC7` / `BC6H` visuals (zero gradient banding), VRAM strictly `<= 5.50 GB`, and zero Maxwell `VK_ERROR_DEVICE_LOST` faults. |
| **Sprint 4** | `v0.9` | Samsung FIT Plus | `vaapi_dmabuf_bridge.hpp` (`iHD` UHD 630 → GTX 980 Ti `NV12`), dedicated `VK_QUEUE_TRANSFER_BIT` + `synchronization2` split barriers, `256 MB BAR1` WC pool, `lsfg-vk 2.0.0+`. | Zero-copy Intel UHD 630 cutscene decode (`0` CPU copies), async DMA texture overlap, and smooth `2×` `lsfg-vk` frame generation within `5.35 GB` VRAM ceiling. |
| **Sprint 5** | **`v1.0` → `v2.00`** | Samsung FIT Plus | Closed-loop `clock_nanosleep` governor, native `GM200` `SHFL` subgroup reductions, `g_metrics` telemetry (`/dev/ttyACM0`), two-stage PGO bake (`STAGE=2`), and Phase 6 VME/RP2040 R&D. | `3 × 15 min` `tmpfs` PGO sweep baked into immutable `< 512 MB` `STAGE=2` EROFS image passing `verify_ax_appliance.sh` (`EXCELLENT_APPLIANCE_READY`). |

---

## 📋 Chapter 5: Step-by-Step Buildroot & C++20 Integration Checklists (`Stages 1–5`)

### Stage 1: Minimal Batocera OS Layer & `toram` Boot (`Sprint 0–1`)

1. **Mirror & Scaffold:** Clone `batocera.linux` and `linux-6.12.y`, cache `NVIDIA-Linux-x86_64-580.126.09.run` in `dl/`, and scaffold `batocera-ax-external/`.
2. **Kernel & Drivers:** Configure Skylake-only `linux.config` (`CONFIG_PREEMPT_RT=y`, `CONFIG_NO_HZ_FULL=y`, `CONFIG_RCU_NOCB_CPU=y`, `CONFIG_CPUSETS_V1=n`, `CONFIG_HUGETLBFS=y`, `CONFIG_ZRAM=y`, `CONFIG_EROFS_FS=y`, `CONFIG_DRM_TTM_HELPER=y`), build `nvidia-driver-legacy580` with `IGNORE_PREEMPT_RT_PRESENCE=1`, and strip Mesa/NVIDIA blobs per Chapter 1.
3. **Init Hooks & Partitioning:** Inject `S01piccolo-isolate`, `S02piccolo-hw` (including async Core 5 `SwitchHDD` mount), `K01piccolo-sync`, and the `initrd` `dd bs=4M` `toram` EROFS loader; format Samsung FIT Plus 64 GB into `4.0 GB FAT32 BATOCERA` + `~55.6 GB ext4 (^has_journal) SHARE`.

### Stage 2: Split Clang 23+ `eden` Package (`Sprint 1`)

1. **Host Clang Wrapper:** Configure `piccolo-clang-x86_64.cmake` pointing to `clang-23` / `lld-23` with `--sysroot=$(STAGING_DIR)` and `-march=skylake -mavx2 -mfma -mbmi -mbmi2 -O3 -flto=thin`.
2. **Headless Build & `ldd` Audit:** Build `eden.mk` with `-DENABLE_QT=OFF -DENABLE_SDL2=ON` and verify `ldd` links strictly against staging `libc`, `libasound`, `libvulkan`, `libva`, and `.

### Stage 3: C++20 Linux Platform Shims & `GM200` Silicon Fastpaths (`src/` `#ifdef __linux__`) (`Sprint 2–5`)

1. **`ax_platform_shim.hpp`:** Fused Core 0 (`0x01`) single-thread `CoreTiming` + `AudioCore` + `SCHED_FIFO 99` `S32_LE` ALSA (`96 frames × 2` / `2.00 ms`, `128-frame` auto-fallback) + `libswresample` micro-pitch PLL (`±0.005%`); `1G` (`6.0 GB`) + `2M` (`2.0 GB`) `MAP_HUGETLB` + `mlockall()`; Core 5 (`0x20`) `SCHED_FIFO 80` `/dev/hidraw*` poller (`-1.5 ms` VBLANK latch + `Select+Start` 1.5s exit hook).
2. **`vk_vram_shield.hpp`, `vk_device.cpp` & `emit_spirv.cpp`:** `VMA_ALLOCATOR_CREATE_EXT_MEMORY_BUDGET_BIT` + VBLANK `VK_EXT_memory_budget` (`5.50 GB` / `5.35 GB` `lsfg-vk`) + `< 64 KB` `texture_reaper.cpp` + VBLANK-gated `BC7`/`BC6H` compute transcoding; runtime `GM200` capability flags (`5.7`) enabling `FP16 → FP32` promotion + compute ASTC default (`5.10`), dedicated `VK_QUEUE_TRANSFER_BIT` + `synchronization2` split barriers (`6.8`), bounded `256 MB BAR1` WC UBO/index pool (`6.9`), and native `SHFL` subgroup reductions (`7.7`).
3. **`vaapi_dmabuf_bridge.hpp`:** Intel UHD 630 `iHD` VA-API decode → `DRM_FORMAT_MOD_LINEAR` `NV12` `dma_buf` FD → GTX 980 Ti `VkImageDrmFormatModifierListCreateInfoEXT`.

### Stage 4: Smart Container Launcher & Lifecycle (`axGenerator.py`) (`Sprint 1–3`)

1. **Launch Sequence:** Parse `.nsp`/`.xci` headers on `SwitchHDD`, strip `0xFF` padding, spawn `taskset -c 5 vmtouch -dql` (`<= 17.5 GB`, clamping if host free RAM nears `5.0 GB`), restore both `/userdata/cache/eden/<TitleID>.tar.zst` and `/userdata/cache/nv/<TitleID>.tar.zst` (`__GL_SHADER_DISK_CACHE_PATH=/dev/shm/nv_cache`) to `tmpfs`, `SIGSTOP` EmulationStation onto Core 5, export `__GL_YIELD=NOTHING`, and launch `eden` in the isolated `Cores 0–4` cgroup.
2. **Exit Sequence:** `SIGTERM` `vmtouch`, atomically flush both `EdenCache` and `/dev/shm/nv_cache` via `tar --zstd -3` (`.tar.zst.tmp` → `sync` → `mv -f`), and `SIGCONT` EmulationStation (`< 50 ms` menu return).

### Stage 5: Quality Gate & Two-Stage PGO Production Bake (`Sprint 5`)

1. **Hardware & Runtime Gate (`verify_ax_appliance.sh`):** Confirm `0` `LOC` timer ticks on Cores `0–4`, `6 × 1G` + `1024 × 2M` HugePages locked, `0` ALSA xruns, `<= 5.35 GB` peak VRAM, `0` mid-game USB flash writes, and `mitigations=off` active.
2. **PGO Sweep & Final Bake:** Execute three representative gameplay sweeps under `BR2_PACKAGE_EDEN_PGO_STAGE=1` (writing `.profraw` to `tmpfs`), merge via `llvm-profdata-23`, recompile `STAGE=2`, assert `< 512 MB` `rootfs.erofs`, and flash the production Samsung FIT Plus image.
