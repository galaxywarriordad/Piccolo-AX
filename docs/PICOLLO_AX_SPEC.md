# ⚡ Eden Piccolo [AX] — Deterministic Appliance Architecture, Engineering Review & Build Guide (v0.6)

> *"Full espresso punch, zero bulky milk—concentrated deterministic Switch emulation on a pocket-sized Samsung USB 3.0 drive."*

* **Document Version:** v0.6 (Reconciled Reference Architecture + 5-Lens Engineering Review, Synced to `ax-sdk v1.36.1` & `Eden-Espresso-Wave-AX` Vulkan 1.4 Async VRAM Shield)
* **Upstream Lineage:** Eden Espresso Wave [AX] (`MASTER v1.35` baseline via `batocera-ax-external/` `BR2_EXTERNAL` overlay + `ax-sdk v1.36.1` shared C++20 silicon core)
* **Target Boot Appliance Medium:** Samsung FIT Plus 64 GB USB 3.1 Gen 1 Flash Drive (Model: `MUF-64AB/APC`, Gunmetal / Steel Grey — up to 400 MB/s read, 60 MB/s write)
* **Target Host Silicon & Memory:** Intel Core i5-9600K (`6C/6T`, Zero SMT, `x48` / `4.8 GHz` locked symmetrically across all Cores 0–5 to avoid Vcore spikes, `x45` / `4.5 GHz` Uncore Ring Lock, 9 MB L3 Smart Cache) · 32 GB Dual-Channel DDR4-3600 (`VCCSA/VCCIO 1.15–1.20V`) · NVIDIA GeForce GTX 980 Ti (6 GB GDDR5, Maxwell GM200, Driver `580.*` Legacy LTS, Vulkan 1.4) + Intel UHD Graphics 630 iGPU (`0x8086`) · HiBy FC3 USB DAC (ESS Sabre ES9281AC Pro)
* **Project Status:** Active Implementation (`ax-sdk v1.36.1` & Vulkan 1.4 Async `VK_QUEUE_TRANSFER_BIT` VRAM Shield Integrated; Ready for Live USB Hardware Gate)
* **Cross-Document References:**
  * `ARCHITECTURE_SPEC.md` — Eden Espresso Wave [AX] Comprehensive Architectural Specification (`MASTER v1.35`)
  * `EDEN_BACKLOG.md` — Eden Espresso Wave [AX] Master Product & Engineering Backlog (`v1.35 → v2.00`)
  * `EDEN_PICCOLO_WORKPACKAGE.md` — Eden Piccolo [AX] Master Implementation Plan & Workpackage (`v0.6`)[cite: 14]

---

## 📑 Table of Contents

1. [Introduction, Executive Narrative & Windows-to-Linux Parity Matrix](#1--introduction-executive-narrative--windows-to-linux-parity-matrix)
2. [Target USB Appliance Hardware & Hybrid Split-Partition Layout](#2--target-usb-appliance-hardware--hybrid-split-partition-layout)
3. [End-to-End Silicon, Ring Bus, Core & Dual-xHCI Isolation Topology](#3--end-to-end-silicon-ring-bus-core--dual-xhci-isolation-topology)
4. [Calibrated 32 GB DDR4-3600 Memory Map, HugePages & Smart Container Filtering](#4--calibrated-32-gb-ddr4-3600-memory-map-hugepages--smart-container-filtering)
5. [Hybrid BC3/BC7 Texture Pipeline, Option C RGBA8 & Dual-GPU Video Offload](#5--hybrid-bc3bc7-texture-pipeline-option-c-rgba8--dual-gpu-video-offload)
6. [Shared `ax-sdk` & Linux C++ / Vulkan 1.4 Platform Shims (`src/`)](#6--shared-ax-sdk--linux-c--vulkan-14-platform-shims-src)
7. [Batocera `BR2_EXTERNAL` Appliance Overlay, Init Hooks & RootFS Pruning](#7--batocera-br2_external-appliance-overlay-init-hooks--rootfs-pruning)
8. [Five-Lens Deep-Dive Engineering Design Review & Risk Audit](#8--five-lens-deep-dive-engineering-design-review--risk-audit)
9. [Phased Integration Roadmap, Timeframes & End-to-End PGO Build Checklist](#9--phased-integration-roadmap-timeframes--end-to-end-pgo-build-checklist)
10. [Legal & Licensing Notice](#10--legal--licensing-notice)[cite: 14]

---

## 1. 🚀 Introduction, Executive Narrative & Windows-to-Linux Parity Matrix

### 1.1 🎯 Why Deterministic Architecture?

Deterministic architecture replaces general-purpose best-effort desktop scheduling with strict, hardware-locked execution guarantees. While desktop operating systems dynamically migrate threads, fire timer ticks, and pause for background services, **Eden Piccolo [AX]** enforces[cite: 14]:

* **Fixed Spatial Boundaries (`CoreRatio=2:3:1`):** Physical CPU cores are partitioned via `ax-sdk` (`ax::topology`), `cgroups v2` (`cpuset.cpus.partition = isolated`), tickless kernels (`nohz_full=0-4`), and offloaded RCU callbacks (`rcu_nocbs=0-4`) to eradicate scheduler jitter and L1/L2/L3 cache pollution.
* **1:1 Cache-Local Interrupt & Bus Alignment:** Hardware MSI interrupts bind directly to the exact physical core consuming their data, eliminating cross-core IPIs and L3 cache-line invalidations.
* **Bounded-Latency Memory & Proactive Async VRAM Pruning:** Page-table walk stalls and PCIe swap thrashing are eliminated using boot-reserved `1 GB` and `2 MB` HugePages, RAM-resident `toram` execution, pre-faulted `vmtouch` asset buffers, and a **proactive `5.00 GiB` (`kPruneTriggerBytes`) asynchronous `VK_QUEUE_TRANSFER_BIT` VRAM reaper** (`VkVramShield`)[cite: 14].

Nintendo Switch emulation is acutely sensitive to tail micro-stutters rather than average frame rates: a single background preemption, synchronous VBLANK memory free, or storage IRQ spike can starve a `2.00–2.67 ms` USB DAC audio buffer or drop a VBLANK frame-pacing deadline[cite: 14]. While **Eden Espresso Wave [AX] (`MASTER v1.35`)** achieves this on Windows 10 via registry hardening, `SeLockMemoryPrivilege`, `HIGH` + MMCSS Pro Audio elevation, and `ax-sdk` spatial masks, **Eden Piccolo [AX]** eliminates the desktop OS entirely—booting an immutable, `< 512 MB` RAM-resident `PREEMPT_RT` Linux appliance from a pocket-sized USB 3.0 drive[cite: 14].

### 1.2 🛠️ What We Are Planning to Build

**Eden Piccolo [AX]** is an out-of-tree `BR2_EXTERNAL` Buildroot overlay (`batocera-ax-external/`) built atop Batocera Linux and linked against the standalone MIT-licensed **`ax-sdk`** C++20 silicon runtime (`ax::core`)[cite: 14]. Every non-[AX] emulator, background desktop daemon, window manager, and user-space audio server (`PipeWire`/`PulseAudio`) is stripped out[cite: 14]. The entire OS resides as a `< 512 MB` read-only **EROFS (`lz4hc,9`)** image on a **Samsung FIT Plus 64 GB USB 3.1 Gen 1 Flash Drive (`MUF-64AB/APC`)**, copying sequentially into DDR4-3600 RAM in `~0.75 seconds` at boot (`toram` with `rootfs.erofs.prev` A/B fallback) so the USB drive sits 100% idle during gameplay[cite: 14].

### 1.3 📊 Architectural Comparison: Eden Espresso Wave [AX] vs. Eden Piccolo [AX]

| Architectural Pillar | Eden Espresso Wave [AX] (`Windows 10 — MASTER v1.35`) | Eden Piccolo [AX] (`Batocera USB 3.0 Appliance — v0.6`) |
| :--- | :--- | :--- |
| **OS Footprint & Boot** | 1.8–3.5 GB Windows 10 + DWM + background services | `< 512 MB` EROFS (`lz4hc,9`) copied to RAM at `initrd` (`toram`, `mitigations=off`, `~0.75s` boot, A/B `.prev` rollback) |
| **CPU Core Isolation** | `ax::topology` (`CoreRatio=2:3:1`) + `HIGH` & MMCSS Pro Audio (prevents USB xHCI IRQ starvation) | `ax::topology` (`CoreRatio=2:3:1`) + `cgroups v2` `isolated` + `isolcpus=managed_irq,domain,0-4` + `nohz_full=0-4` + `rcu_nocbs=0-4` |
| **HugePages & Fastmem** | `SeLockMemoryPrivilege` + `VirtualAlloc(MEM_LARGE_PAGES)` (2 MB) | Hybrid **`6.0 GB` (1G DTLB)** + **`2.0 GB` (2M)** HugePages (`8.0 GB` total) + `mmap(MAP_HUGETLB)` + `mlockall()` |
| **Bit-Perfect Audio** | FlexASIO / WASAPI Exclusive (`WIN32`-gated in CMake, 128 smp / 2.67 ms) + MMCSS Pro Audio | Unified Core 0 loop: Direct ALSA `hw:CARD=FC3,DEV=0` (`S32_LE`, `96` smp / `2.00 ms` w/ `128` fallback) + HiBy FC3 xHCI IRQ (`itr=0`) |
| **Async VRAM Shield** | `ax::vram` **`5.00 GiB` async prune trigger** + `VkVramShield` (`VK_QUEUE_TRANSFER_BIT` + `vkCmdSetEvent2`/`WaitEvents2`) | `ax::vram` **`5.00 GiB` async prune trigger** (`~4.50 GiB` hysteresis recovery) + `VkVramShield` (`5.50 GiB` / `5.35 GiB` w/ `lsfg-vk 2.0.0+`) |
| **GM200 Silicon Fastpaths** | Runtime PCI ID flags (`5.7`): `FP16 → FP32` promotion, dedicated `VK_QUEUE_TRANSFER_BIT`, `BAR1` WC pool | Runtime `GM200` flags (`5.7`): `FP16 → FP32` shader promotion (`5.10`), dedicated `VK_QUEUE_TRANSFER_BIT` (`6.8`), `BAR1` WC pool (`6.9`), `SHFL` (`7.7`) |
| **Texture Pipeline** | Hybrid BC3/BC7 + Option C `< 4.5 GB` lossless RGBA8 | VBLANK-gated Maxwell async compute ASTC → BC3/BC7 (Core 5 SIMD fallback) + Option C `< 4.5 GB` RGBA8 per-title toggle |
| **Frame Generation** | Native Win32 `Lossless.dll` DXGI / WinRT WGC swapchain hook | Implicit Vulkan Layer **`lsfg-vk 2.0.0+`** (Vulkan 1.2 bindless, FP32 mode, BYO licensed Steam `Lossless.dll`) |
| **iGPU Video Offload** | Media Foundation / Intel QSV + `IDXGIResource1` NT Shared Handle | Intel UHD 630 VA-API (`iHD`) → `DRM_FORMAT_MOD_LINEAR` `dma_buf` FD → `VkImageDrmFormatModifierListCreateInfoEXT` |
| **IRQ & Workqueue Steering** | PowerShell `Scripts\set_irq_affinity.ps1` + runtime MSI helper (`6.7`) | Early `/etc/init.d/S01piccolo-isolate` (`workqueue/cpumask=0x20`, `pcie_aspm=off`, 1:1 MSI IRQ affinity) |
| **Storage & Persistence** | NVMe #1 (OS/Shaders) · NVMe #2 (Updates/DLC) · 7200 RPM HDD | Samsung FIT Plus USB 3.0 (`toram` boot + atomic `zstd -3` `.tar.zst` exit sync for `EdenCache` & `nv_cache`) + `SwitchHDD`[cite: 14]

---

## 2. 💾 Target USB Appliance Hardware & Hybrid Split-Partition Layout

### 2.1 🔌 Selected Boot Medium: Samsung FIT Plus 64 GB (`MUF-64AB/APC`)

* **Interface & Speeds:** USB 3.1 Gen 1 interface (backward-compatible with USB 3.0/2.0) delivering up to **400 MB/s sequential read** and **60 MB/s sequential write** speeds.
* **Durability & Form Factor:** Ultra-compact plug-and-stay profile minimizing physical knock risk, backed by 5-proof resilience (water, shock, magnet, temperature, and X-ray proof).
* **Zero-Runtime-Write Strategy:** To avoid the 60 MB/s NAND write ceiling and eliminate flash wear during active gameplay, runtime writes to the USB drive are completely prohibited:
  * At `initrd` stage, the `< 512 MB` EROFS rootfs is copied sequentially (`bs=4M`, with automatic fallback to `rootfs.erofs.prev`) into a RAM `tmpfs` block in `~0.75s`.
  * Active shader caches (`EdenCache` + `__GL_SHADER_DISK_CACHE_PATH=/dev/shm/nv_cache`), AOT blocks, logs, and PGO `.profraw` traces reside strictly in DDR4-3600 `tmpfs` (`1.5 GB`).
  * On game exit or shutdown, `/etc/init.d/K01piccolo-sync` and `axGenerator.py` pack dirty cache data into contiguous **`zstd -3`** archives written atomically (`.tar.zst.tmp` → `sync` → `mv -f`) at full `60 MB/s` sequential throughput[cite: 14].

### 2.2 🗂️ Hybrid Split-Filesystem Partition Layout

| Partition | Size & Filesystem | Mount Point & Options | Contents & Engineering Safeguards |
| :--- | :--- | :--- | :--- |
| **1. `BATOCERA`** | `4.0 GB` `FAT32` | `/boot` (`ro,noatime`) | UEFI bootloaders, multi-core GRUB config (`mitigations=off`), mainline Linux `6.12.x-rt` `bzImage`, and immutable `< 512 MB` EROFS (`lz4hc,9`) rootfs image (`rootfs.erofs` + A/B fallback `rootfs.erofs.prev`). |
| **2. `SHARE`** | `~55.6 GB` `ext4` (journal disabled) | `/userdata` (`rw,noatime,commit=60`) | Formatted with `mkfs.ext4 -O ^has_journal` to eliminate metadata write amplification; stores `eden_engine.ini`, `eden.profdata`, and per-title `.tar.zst` `EdenCache` + `nv_cache` archives. Protected at boot by mandatory `e2fsck -p` inside `S01piccolo-isolate`.[cite: 14]

---

## 3. 🧠 End-to-End Silicon, Ring Bus, Core & Dual-xHCI Isolation Topology

### 3.1 🏗️ Hardware & Execution Domain Blueprint (`CoreRatio=2:3:1`)

| Domain / Subsystem | Hardware / Partition | Allocation & Configuration | Execution & Data-Flow Role |
| :--- | :--- | :--- | :--- |
| **Boot Medium** | Samsung FIT Plus 64 GB (`MUF-64AB/APC`) | `4.0 GB` `FAT32` (`BATOCERA`, RO) + `55.6 GB` `ext4` (`SHARE`, `^has_journal`) | Sequential `toram` EROFS copy (`~0.75s`); atomic `.tar.zst` exit sync only; zero mid-game flash writes. |
| **System Memory** | 32 GB Dual-Channel DDR4-3600 | `6.0 GB` (`1G`) + `2.0 GB` (`2M`) HugeTLB · `17.5 GB` `vmtouch` · `5.0 GB` Host + `512 MB` `zram` · `1.5 GB` `tmpfs` | `512 GB` contiguous guest `fastmem` (`_bextr_u64` BMI1), filtered NCA RAM buffer, and RAM shader caches. |
| **Emulation Domain** | Intel Core i5-9600K Cores `0–4` | `cgroups v2` `isolated` · `nohz_full=0-4` · `rcu_nocbs=0-4` · Symmetrical `x48` (`4.8 GHz`) · Ring `x45` (`4.5 GHz`) | **Core 0 (`4.8 GHz`):** Fused `CoreTiming` + `AudioCore` + `SCHED_FIFO 99` ALSA + HiBy FC3 IRQ (`itr=0`).<br>**Core 1 (`4.8 GHz`):** `VulkanWorker`, `GPUDirtyMemoryManager::Gather()`, `VkVramShield::TickVblank()`, GTX 980 Ti MSI IRQ.<br>**Cores 2–4 (`4.8 GHz`):** Guest ARM Cores `0–2` home-biased Dynarmic JIT fibers. |
| **Housekeeping Domain** | Intel Core i5-9600K Core `5` (`0x20`) | `workqueue/cpumask=0x20` · `default_smp_affinity=0x20` · `4.8 GHz` | Kernel kworkers, SATA AHCI (`SwitchHDD`), USB boot/HID IRQs, Core 5 `VkVramShield` async `VK_QUEUE_TRANSFER_BIT` reaper thread, Guest ARM Core `3` (`0x3C`), `1x` SPIR-V worker, FFmpeg `execute2` slices, `/dev/hidraw*` (`FIFO 80`), `/dev/ttyACM0`, `SIGSTOP` EmulationStation. |
| **Discrete GPU (dGPU)** | NVIDIA GeForce GTX 980 Ti (6 GB GDDR5) | PCIe 3.0 x16 · `pcie_aspm=off` · `nvidia-smi -pm 1` · Driver `580.*` LTS (Vulkan 1.4) | Primary 3D rasterizer (`5.00 GiB` async prune trigger / `5.50 GiB` & `5.35 GiB` ceilings), GM200 `FP16 → FP32`, dedicated `VK_QUEUE_TRANSFER_BIT` (`6.8`), `256 MB` `BAR1` WC pool, `lsfg-vk 2.0.0+` (FP32). |
| **Integrated GPU (iGPU)** | Intel UHD Graphics 630 (`0x8086`) | `intel-media-driver` (`iHD`) VA-API | Offloads H.264/HEVC/VP8/VP9 video decode; exports `DRM_FORMAT_MOD_LINEAR` `dma_buf` FD directly to GTX 980 Ti via `VkImageDrmFormatModifierListCreateInfoEXT`. |
| **Dual xHCI Audio Bus** | Discrete xHCI Controller #2 → HiBy FC3 DAC | Physically isolated PCIe BDF · `S32_LE` / `48 kHz` (`96` / `128` smp) | Isolates ESS Sabre ES9281AC Pro isochronous transfers (`2.00–2.67 ms`) from PCH xHCI #1 storage/HID traffic.[cite: 14] |

### 3.2 📌 Core Execution & Interrupt Pinning Rules

* **Core 0 (`4.8 GHz` Symmetrical BIOS `x48` Lock — Unified L2 Cache-Local Audio & Timing Domain):**
  * **Single Runnable User Thread (`nohz_full` Compliance):** Linux `CONFIG_NO_HZ_FULL` only suppresses the `1,000 Hz` scheduler tick when `<= 1` runnable task exists in a core's runqueue. Piccolo fuses `Core::Timing::CoreTiming`, `AudioCore` DSP graph compilation, and the `SCHED_FIFO` priority `99` direct ALSA feeder (`hw:CARD=FC3,DEV=0` + `libswresample` micro-pitch PLL `±0.005%`) into a single event-driven thread on Core 0.
  * **1:1 xHCI DAC IRQ Binding:** The MSI interrupt of the dedicated xHCI controller hosting the HiBy FC3 DAC is pinned exclusively to Core 0 (`smp_affinity = 0x01`) with interrupt moderation disabled (`itr=0`). The entire `2.00–2.67 ms` PCM ring stays resident inside Core 0's private `256 KB` L2 cache with zero cross-core L3 invalidations.
* **Core 1 (`4.8 GHz` — Dedicated Vulkan Submission, Dirty-Memory Gather & VBLANK Poll):**
  * Hosts `VulkanWorker` command submission (`vk_scheduler.cpp`), AVX2/BMI2 `GPUDirtyMemoryManager::Gather()` page-table bit-scans, non-blocking `< 5 µs` `VkVramShield::TickVblank()` budget evaluation, and the GTX 980 Ti PCI-MSI interrupt (`smp_affinity = 0x02`, `__GL_YIELD=NOTHING`).
* **Cores 2–4 (`4.8 GHz` — Tickless Guest ARM JIT Domain):**
  * Home-biased `Common::Fiber` pool executing Guest ARM Cores `0–2` Dynarmic JIT blocks (`_bextr_u64` single-cycle BMI1 address translation) under `nohz_full` + `rcu_nocbs` with zero scheduler ticks.
* **Core 5 (`4.8 GHz` — `0x20` Housekeeping, Async VRAM Reaper & Horizon OS Quarantine Sink):**
  * Captures all unbound kernel kworker threads (`/sys/devices/virtual/workqueue/cpumask = 0x20`), `rcu_nocbs` callback threads, `SwitchHDD` SATA AHCI IRQs, USB boot/HID IRQs, Core 5 `VkVramShield` `std::jthread` async VRAM destruction worker (`ax::topology::Domain::Housekeeping`), Guest ARM Core `3` Horizon OS service fibers (`ElasticGuestPool = 0x3C`), single-worker SPIR-V compilation (`ASYNC_WORKER_CORE_CLAMP = 1`), FFmpeg `execute2` decode slices, `SCHED_FIFO 80` `/dev/hidraw*` input polling, `/dev/ttyACM0` telemetry output, and `SIGSTOP`-suspended EmulationStation (engaging `_MM_HINT_NTA` non-temporal prefetching on Core 5 streaming reads if `rdmsr 0xc8f` reports Intel CAT fused off on desktop Coffee Lake).[cite: 14]

### 3.3 ⚡ BIOS, Uncore Ring Bus & PCIe/DMI 3.0 Rules

* **Symmetrical Core & Uncore Ring Ratio Lock (`x48` All-Core / `x45` Uncore Ring):** Lock all Cores `0–5` symmetrically to `x48` (`4.8 GHz`, avoiding Vcore spikes) and lock the Coffee Lake Ring Bus to `x45` (`4.5 GHz`, `300 MHz` below the `4.8 GHz` all-core floor) with Ring Downbin = Disabled and AVX Offset = 0 to eliminate variable L3 cache latency during Core 1 `Gather()` scans and Cores `2–4` JIT misses.
* **System Agent Voltages (`VCCSA` / `VCCIO`):** Pin `VCCSA = 1.15–1.20 V` and `VCCIO = 1.15 V` in Z390 BIOS (preventing Auto over-volting on 32 GB DDR4-3600) and tighten `tREFI = 65535` to cut DRAM refresh stalls.
* **Zero C-State Wake Jitter:** Set `processor.max_cstate=0` (`POLL` idle loop on isolated cores), `mitigations=off`, and `pcie_aspm=off` + `/sys/bus/pci/devices/0000:01:00.0/power/control = on` + `nvidia-smi -pm 1` so neither the CPU cores nor the GTX 980 Ti incur wake-up or speculative-mitigation latency spikes.[cite: 14]

---

## 4. 🧮 Calibrated 32 GB DDR4-3600 Memory Map, HugePages & Smart Container Filtering

With `vm.swappiness=1` and a `512 MB` LZ4 `zram` emergency compression valve pinned to Core 5 (writing zero bytes to USB/HDD), Piccolo partitions its **32.0 GB** dual-channel DDR4-3600 memory into five deterministic tiers[cite: 14]:

| Memory Tier | Allocation | Kernel / Runtime Mechanism | Architectural Purpose |
| :--- | :--- | :--- | :--- |
| **1A. 1 GB HugePages** | **6.0 GB** (`hugepagesz=1G hugepages=6`) | Boot-reserved `1G` DTLB pages via `mmap(MAP_HUGETLB \| MAP_HUGE_1GB)` + `mlockall()` | Backs the `512 GB` contiguous guest `fastmem` arena and Dynarmic JIT code cache (`512 MB`), eliminating Skylake second-level TLB (STLB) page walks. |
| **1B. 2 MB HugePages** | **2.0 GB** (`hugepagesz=2M hugepages=1024`) | Boot-reserved `2M` HugePages via `mmap(MAP_HUGETLB \| MAP_HUGE_2MB)` | Allocates Vulkan staging rings, audio PCM rings, and VA-API `dma_buf` linear video surfaces. |
| **2. Priority Asset Buffer** | **17.5 GB** (`16/17.5/19/auto`) | `taskset -c 5 vmtouch -dql` (`MAP_POPULATE` bulk pre-faulting; `ulimit -l unlimited`) | Pins container-filtered game NCAs in DDR4-3600 RAM to eliminate mechanical `SwitchHDD` seek stalls (`10–14 ms`). Dynamically clamps if free host RAM `< 5.0 GB`. |
| **3. Host Safety Floor + `zram`** | **5.0 GB** (+ `512 MB` LZ4 `zram`) | `6.12-rt` kernel + `< 512 MB` `toram` EROFS + NVIDIA `580.*` / Intel `iHD` driver heaps | Guarantees zero OOM kills during heavy SPIR-V shader compilation or driver memory spikes, backed by a zero-disk-I/O LZ4 `zram` safety valve on Core 5. |
| **4. Per-Title `EdenCache` + NV** | **1.5 GB** (`tmpfs`) | Loaded from `SHARE` (`/userdata/cache/`) at launch; atomic `.tar.zst` flush on exit | Stores active TitleID Vulkan pipeline caches (`EdenCache`) and NVIDIA GLCache (`/dev/shm/nv_cache`) in RAM with atomic `zstd -3` persistence on exit.[cite: 14]

### 📦 Smart Container Inspection (`axGenerator.py`)

Before launching `vmtouch -dql` from `SwitchHDD`, `axGenerator.py` inspects `.nsp`/`.xci` NCA headers to[cite: 14]:

1. **Strip Dummy Padding:** Exclude `0xFF` cartridge padding sectors so only valid game data consumes RAM.
2. **Prioritize Hot Code & Patches:** Pin Update/DLC NCAs, `.nso` executable code, and hot world-streaming archives first.
3. **Exclude Streaming Cutscenes:** Leave pre-rendered VP8/VP9/H.264 video files on `SwitchHDD` for sequential streaming directly through the Intel UHD 630 VA-API hardware decoder.
4. **Clean Exit Teardown:** Explicitly terminates the `vmtouch -dl` daemon (`kill -TERM`) on game exit before `K01piccolo-sync` runs so locked pages return immediately to the kernel pool.[cite: 14]

---

## 5. 🎨 Hybrid BC3/BC7 Texture Pipeline, Option C RGBA8 & Dual-GPU Video Offload

### 5.1 🖼️ Proactive `5.00 GiB` Async VRAM Shield & GM200 Silicon Pipeline (`GTX 980 Ti` 6 GB GDDR5)

Because the Maxwell GM200 lacks native hardware ASTC decoding and runs FP16 at a **1:64** rate relative to FP32, Piccolo combines **Option C lossless detection**, **runtime `GM200` capability flags (`5.7`)**, **VBLANK-gated GPU compute transcoding**, and an **asynchronous `VK_QUEUE_TRANSFER_BIT` + Vulkan 1.4 Synchronization2 split-barrier VRAM reaper (`VkVramShield`)**[cite: 14]:

* **GM200 `FP16 → FP32` Shader Promotion & Compute ASTC Default (`5.10`):** When runtime PCI ID detection (`5.7`) identifies Maxwell `GM200`, `emit_spirv.cpp` automatically promotes Switch `FP16`/`mediump` ALU operations to native `FP32` (eliminating half-precision ALU stalls) and defaults ASTC decompression to GPU compute shaders across GM200's 2,816 CUDA cores to protect `0x1C` CPU headroom.
* **Dedicated `VK_QUEUE_TRANSFER_BIT` Discovery & `256 MB BAR1` WC Fastpath (`6.8` & `6.9`):** `Vulkan::Device::SetupFamilies()` scans queue families to isolate GM200's dedicated hardware DMA copy engine (`VK_QUEUE_TRANSFER_BIT` without `VK_QUEUE_GRAPHICS_BIT`, exposed via `device.GetTransferQueue()` / `device.HasDedicatedTransferQueue()` with automatic `graphics_family` fallback), overlapping texture transfers with 3D rasterization alongside a bounded sub-pool carved out of GM200's `256 MB BAR1` `HOST_VISIBLE | DEVICE_LOCAL` Write-Combined aperture.
* **Proactive `5.00 GiB` Async Split-Barrier VRAM Shield (`ax::vram` + `VkVramShield`):**
  * **Zero-Stall VBLANK Poll (Core 1):** During `RasterizerVulkan::TickFrame()`, `VkVramShield::TickVblank()` queries `device.GetDeviceMemoryUsage()` (`VK_EXT_memory_budget`) and calls `ax::vram::EvaluateBudget(current_usage, lsfg_active, IsEvictionInFlight())`.
  * **Proactive `5.00 GiB` Trigger (`kPruneTriggerBytes = 5,368,709,120` bytes):** Rather than waiting until the `5.50 GiB` (`5.35 GiB` with `lsfg-vk 2.0.0+`) hard ceiling—and never blocking VBLANK with synchronous `vmaDestroyImage` / `vkDestroyImage` calls—eviction triggers asynchronously at **`5.00 GiB`** with a **`~4.50 GiB` hysteresis recovery target** and an atomic `eviction_in_flight` guard.
  * **Vulkan 1.4 Synchronization2 Split Barrier + Core 5 Reaper:** Core 1 records a non-blocking `vkCmdSetEvent2` → `vkCmdWaitEvents2` split barrier (`VK_PIPELINE_STAGE_2_ALL_GRAPHICS_BIT` → `VK_PIPELINE_STAGE_2_TRANSFER_BIT`), submits a `VK_KHR_timeline_semaphore` ticket on `device.GetTransferQueue()`, and signals a dedicated `std::jthread` worker pinned to **Core 5 (`ax::topology::Domain::Housekeeping`)** to release detached `VmaAllocation` / `VkImage` handles completely off the VBLANK critical path.
  * **Emergency Hard-Ceiling Guardrail:** If a sudden allocation spike reaches the `5.50 GiB` (`5.35 GiB` LSFG) ceiling before the async worker finishes draining, `snapshot.force_lod_downscale` engages immediately.
* **Option C Hybrid Uncompressed RGBA8 Tier (`< 4.5 GB` VRAM Footprint):** For lighter titles whose total uncompressed texture + framebuffer footprint stays safely under `4.5 GB`, `axGenerator.py` enables per-title lossless RGBA8 mode, preserving native Switch visual fidelity with zero compression artifacts.
* **VBLANK-Gated Async Compute ASTC → BC3/BC7 Transcoding:** For heavy titles (`>= 4.5 GB` uncompressed), raw ASTC blocks upload into a compact `2M` HugePage staging ring and transcode in parallel on the GTX 980 Ti into **BC3** (`1.0 BPP` active baseline) or **BC7/BC6H** (`1.0 BPP` Phase 3 parity) directly in VRAM—cutting PCIe upload traffic in half and keeping active VRAM between **2.2 GB and 3.2 GB**.
  * *Maxwell Single-Engine Guardrail:* Because Maxwell GM200 time-slices compute and graphics on a single engine, GPU compute transcoding is gated to loading screens and VBLANK slack windows, dynamically routing ASTC transcoding to **Core 5 AVX2 SIMD** whenever `lsfg-vk` frame generation is active (`frame_time > 12.0 ms`).[cite: 14]

### 5.2 🎬 Zero-Copy Intel UHD 630 → GTX 980 Ti Video Bridge (`vaapi_dmabuf_bridge.hpp`)

* Hardware video decode (H.264, HEVC, VP8, VP9) executes on the **Intel UHD Graphics 630** via `intel-media-driver` (`iHD` VA-API)[cite: 14].
* Decoded NV12 frames export as linear `dma_buf` file descriptors (`vaExportSurfaceHandle` with `VA_SURFACE_ATTRIB_MEM_TYPE_DRM_PRIME_2` and `DRM_FORMAT_MOD_LINEAR`)[cite: 14].
* **NVIDIA Modifier List Import:** To avoid NVIDIA's driver rejection of explicit modifier layouts on multi-plane NV12 buffers, `vaapi_dmabuf_bridge.hpp` imports the `dma_buf` FD on the GTX 980 Ti via **`VkImageDrmFormatModifierListCreateInfoEXT`** (`{ DRM_FORMAT_MOD_LINEAR }`) and `VK_KHR_external_memory_fd`, achieving true zero-copy GPU-to-GPU cutscene presentation[cite: 14].

---

## 6. ⚙️ Shared `ax-sdk` & Linux C++ / Vulkan 1.4 Platform Shims (`src/`)

All silicon-policy logic lives in the MIT-licensed **`ax-sdk`** (`ax::core`) library consumed via CMake `FetchContent` / Buildroot `package/ax-sdk/`, while Linux-native hardware bindings live behind `#ifdef __linux__` guards inside `src/` to maintain a unified C++20 codebase with Windows `MASTER v1.35`[cite: 14].

### 6.1 🧩 Core Platform & Hardware Shims

* **`ax-sdk` (`include/ax/{topology,memory,vram,igpu,audio}.hpp`):**
  * **`ax::vram` (`v1.35.0`):** Exposes `kPruneTriggerBytes` (`5.00 GiB`), `kDefaultCeilingBytes` (`5.50 GiB`), `kLsfgCeilingBytes` (`5.35 GiB`), `kWin32LsCeilingBytes` (`5.20 GiB`), and `EvaluateBudget(usage, lsfg, eviction_in_flight)` with `~4.50 GiB` recovery hysteresis.
  * **`ax::topology`:** Enforces `CoreRatio=2:3:1` domain pinning (`AudioTiming`, `VulkanSubmission`, `GuestJit`, `Housekeeping`), Linux `/dev/cpu/0/msr` (`0xc8f`) CAT availability detection, and Windows `HIGH` + MMCSS `Pro Audio` elevation.
  * **`ax::memory` & `ax::igpu`:** Provides `MAP_HUGE_1GB` / `MAP_HUGE_2MB` HugeTLB fastmem allocation, `_bextr_u64` BMI1 helpers, `_MM_HINT_NTA` non-temporal streaming hints, and `DRM_FORMAT_MOD_LINEAR` `dma_buf` bandwidth guardrails (`3.50 GB/s`).
* **`src/video_core/renderer_vulkan/vk_vram_shield.hpp`, `vulkan_device.cpp` & `vulkan_wrapper.cpp`:**
  * Discovers dedicated `VK_QUEUE_TRANSFER_BIT` hardware queues (`device.GetTransferQueue()`), loads Vulkan 1.4 `vkCmdSetEvent2` / `vkCmdWaitEvents2` (with `KHR` fallbacks), and runs `Vulkan::VkVramShield` (`TickVblank` on Core 1 + `VK_KHR_timeline_semaphore`-fenced `std::jthread` reaper on Core 5).
* **`src/common/ax_platform_shim.hpp` (Unified Core 0 Audio & Closed-Loop Governor):**
  * Pins the fused `CoreTiming` + `AudioCore` + `SCHED_FIFO 99` ALSA feeder loop (`hw:CARD=FC3,DEV=0`, `SND_PCM_FORMAT_S32_LE`, `48 kHz`, `96-frame / 2.00 ms` default period with automatic `128-frame / 2.67 ms` xrun fallback + `libswresample` micro-pitch PLL `±0.005%`) to **Core 0 (`0x01`)**.
  * Implements the **closed-loop `clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME)` + `_mm_pause()`** sub-microsecond frame-pacing governor driven by lock-free `g_metrics` atomic counters.
  * Runs the `SCHED_FIFO 80` `/dev/hidraw*` VBLANK-aligned (`-1.5 ms` phase latch + `Select+Start` 1.5s exit hook) controller poller and `/dev/ttyACM0` 3.5" telemetry writer on **Core 5 (`0x20`)**.
* **`src/video_core/host1x/vaapi_dmabuf_bridge.hpp`:**
  * Manages Intel `iHD` VA-API session creation, `DRM_FORMAT_MOD_LINEAR` `dma_buf` export, and `VkImageDrmFormatModifierListCreateInfoEXT` Vulkan import on the GTX 980 Ti.[cite: 14]

### 6.2 🛡️ Maxwell GM200 Safety Guards & Upstream PR Parity (`MASTER v1.35`)

* **Maxwell Descriptor, Subresource & Page Guards (`Citron PR #449, #383, #4688, #385, #447, #448`):** Enforces `(addr & YUZU_PAGEMASK) + size <= YUZU_PAGESIZE` contiguity checks on `vk_ubo_passthrough.cpp` / `dma_ring_bridge.cpp`, clamps GTX 980 Ti `maxPushDescriptors` with null-descriptor fallbacks, bounds `VkImageSubresourceRange` mip/layer counts in `vk_texture_cache.cpp`, and short-circuits zero-vertex procedural draws (`gl_VertexIndex`).
* **Register-Pressure (`lmem`) Spill Guard & Native `SHFL` Reductions (`emit_spirv.cpp` — `7.3` & `7.7`):** Condenses SPIR-V temporary live ranges and emits native `VK_KHR_shader_subgroup_arithmetic` / `vote` 32-thread warp shuffle instructions (`SHFL`) instead of shared-memory (`LDS`) fallbacks so complex shaders stay within Maxwell's hardware register file instead of spilling into GDDR5 local memory (`lmem`).
* **FFmpeg Core 5 Slice Quarantine & AVX2 Audio (`nvdec.h`, `vp8.cpp`, `vp9.cpp`):** Routes any software decode fallback slices strictly into Core 5's `PipelineWorkerPoolRing` (`0x20`) and enables AVX2 FIR resampling + `SWR_DITHER_TRIANGULAR_HIGHPASS` in `libswresample`.
* **64-Bit Pipeline Key Condensation, Biquad Guard & Memory Leak Fix (`Eden PR #4819, #4210, #3817, #2`):** Compresses `FixedPipelineState` into Skylake L1/L2 cache lines, guards `BiquadFilterEffectCommand` coefficients on Core 0, and includes PR #3817 (`HeapTracker` removal) to guarantee zero host RAM leaks over multi-hour sessions.[cite: 14]

---

## 7. 🐧 Batocera `BR2_EXTERNAL` Appliance Overlay, Init Hooks & RootFS Pruning

### 7.1 🏗️ Out-of-Tree Buildroot Architecture (`batocera-ax-external/`)

* **Split Compiler Toolchain:** Base Buildroot host/target packages (`glibc`, `busybox`, `mesa3d`, `alsa-lib`, `linux 6.12-rt`, `nvidia-driver-legacy580`) compile with GCC to prevent inline-ASM and linker breakages. A standalone host Clang 23+ + LLD + `llvm-profdata` toolchain (`ax-sdk/ax_toolchain/piccolo-clang-x86_64.cmake`) compiles `eden-ax`, `cemu-latte-ax`, and `rmg-ax` exclusively (`-march=skylake -mavx2 -mfma -mbmi -mbmi2 -flto=thin` + two-stage PGO), while Windows-only `asio_sdk` and `FlexASIO` dependencies are gated under `if (WIN32)` in `externals/CMakeLists.txt`.
* **Pinned Kernel & Maxwell Driver:**
  * **Mainline Linux `6.12.x` LTS (`CONFIG_PREEMPT_RT=y`, `mitigations=off`):** Eliminates out-of-tree RT patch drift; compiles `SATA_AHCI`, `USB_XHCI_HCD`, `SND_USB_AUDIO`, `DRM_I915`, `EROFS_FS`, and `ZRAM` directly into `bzImage` (`=y`).
  * **Hard-Pinned NVIDIA `580.*` Legacy LTS (`580.126.09`):** Final official NVIDIA branch supporting Maxwell `GM200` (`590+` drops Maxwell), built with `IGNORE_PREEMPT_RT_PRESENCE=1` and `CONFIG_DRM_TTM_HELPER=y`. Open-source `NVK`/`Nouveau` is explicitly excluded due to non-GSP Maxwell P0 reclocking limits.
* **Aggressive `< 512 MB` EROFS RootFS Pruning (`post-build.sh` & `post-image.sh`):**
  * Strips `~200+ MB` of unused NVIDIA compute blobs (`libcuda.so*`, `libnvidia-ptxjitcompiler.so*`, `libnvidia-nvvm.so*`, `libnvidia-opencl.so*`, `libnvidia-optix.so*`, `libnvidia-encode.so*`, `libnvidia-fbc.so*`) and `~80 MB` of Mesa Gallium/`llvmpipe`/LLVM libraries, retaining only NVIDIA Vulkan/GLX + Intel `iHD` VA-API.
  * Purges `PipeWire`, `PulseAudio`, `Openbox`, `avahi-daemon`, `bluetoothd`, `ntpd`, and `rngd`, packing the rootfs as EROFS (`mkfs.erofs -zlz4hc,9`) (`~360–430 MB`, enforced `< 512 MB` in `post-image.sh`) for `~0.75s` `toram` boot.[cite: 14]

### 7.2 ⚡ Early Init (`S01piccolo-isolate`) & Atomic Exit Sync (`K01piccolo-sync`)

* **`/etc/init.d/S01piccolo-isolate` (Runs Before Network/Audio/Display Services):**
  1. Enforces pure `cgroup v2` unified hierarchy and configures `/sys/fs/cgroup/eden.slice` (`cpuset.cpus = 0-4`, `cpuset.cpus.partition = isolated`).
  2. Pins `/sys/devices/virtual/workqueue/cpumask` and `/proc/irq/default_smp_affinity` to `0x20` (Core 5), while binding the HiBy FC3 xHCI MSI IRQ to `0x01` (Core 0, `itr=0`) and GTX 980 Ti MSI IRQ to `0x02` (Core 1).
  3. Configures `512 MB` LZ4 `zram` swap on Core 5 (`vm.swappiness=1`), `vm.max_map_count=1048576`, `ulimit -l unlimited`, `pcie_aspm=off`, `nvidia-smi -pm 1`, and `/etc/modprobe.d/piccolo-audio.conf` (`options snd-usb-audio nrpacks=1 lowlatency=1`).
  4. Runs `e2fsck -p` on the journal-free `SHARE` partition (`/dev/sdX2`) before mounting `/userdata`.
* **Display & Front-End Lifecycle (`axGenerator.py`):**
  * Launches EmulationStation on a bare, uncomposited Xorg server (`Option "AllowFlipping" "True"`, `Option "TripleBuffer" "False"`, `__GL_YIELD=NOTHING`, `__GL_SHADER_DISK_CACHE_PATH=/dev/shm/nv_cache`), or acquires the display directly via `VK_KHR_display` DRM lease when `lsfg-vk` is disabled.
  * During gameplay, `SIGSTOP`-freezes EmulationStation and moves its PID into Core 5 (`0x20`), reclaiming `~200 MB` VRAM and `~250 MB` RAM with `< 50 ms` resume on exit.
* **`/etc/init.d/K01piccolo-sync` (Atomic Exit & Shutdown Hook):**
  * Terminates `vmtouch -dl`, packs both `EdenCache` (`tmpfs`) and `/dev/shm/nv_cache` shader caches and `.profraw` traces with `zstd -3` into `<TitleID>.tar.zst.tmp`, executes `sync`, and atomically renames (`mv -f`) over `<TitleID>.tar.zst`—preventing truncated shader-cache crashes (Eden Issue #771) on sudden power loss.[cite: 14]

---

## 8. 🔍 Five-Lens Deep-Dive Engineering Design Review & Risk Audit

To validate that Eden Piccolo [AX] v0.6 extracts maximum deterministic performance from the target silicon without hidden bottlenecks, the architecture was audited across five engineering lenses and hardened with concrete runtime defenses[cite: 14].

### 📋 Summary of Findings Across All 5 Review Lenses

| Review Lens | Critical Finding / Bottleneck Identified | Architectural Resolution Baked into v0.6 | Measured / Expected Gain |
| :--- | :--- | :--- | :--- |
| **1. Silicon, Ring Bus & Core Execution** | Linux `nohz_full` disables tickless mode if `>= 2` runnable tasks share Core 0; raw `REALTIME` priority risks starving USB xHCI IRQs; static `0x1C` masks collide on SMT CPUs. | Fused `CoreTiming` + `AudioCore` + ALSA into 1 runnable thread on Core 0; clamped Win32 `HostTimingPriorityClass=HIGH` + MMCSS `Pro Audio`; added `CoreRatio=2:3:1`, `rcu_nocbs=0-4`, `isolcpus=managed_irq,domain,0-4`, `max_cstate=0`, `mitigations=off`, Z390 Symmetrical `x48` + Ring `x45`, and `rdmsr 0xc8f` CAT probe (`_MM_HINT_NTA` fallback on Core 5). | True `0` timer ticks on Cores `0–4`; `> 80%` Core 0 idle headroom at symmetrical `4.8 GHz` (zero Vcore spikes); zero USB IRQ starvation. |
| **2. Dual-GPU Vulkan 1.4 & Async VRAM Pipeline** | Synchronous VBLANK VRAM compaction causes frame-time spikes; NVIDIA rejects `ExplicitCreateInfoEXT` on `NV12 dma_buf`; GM200 FP16 runs at `1:64` rate. | Implemented `VkVramShield` with `5.00 GiB` proactive prune trigger (`~4.50 GiB` hysteresis), dedicated `VK_QUEUE_TRANSFER_BIT`, Vulkan 1.4 `vkCmdSetEvent2`/`WaitEvents2` split barriers, and a `VK_KHR_timeline_semaphore`-fenced Core 5 reaper; used `VkImageDrmFormatModifierListCreateInfoEXT`; added GM200 `FP16 → FP32` promotion (`5.10`), `BAR1` WC pool (`6.9`), `SHFL` (`7.7`), and `lsfg-vk 2.0.0+` (`5.35 GiB` cap). | Eliminated VBLANK eviction frame-time spikes; `0.50 GiB` headroom before Maxwell VRAM ceiling; zero-copy UHD 630 → GTX 980 Ti video. |
| **3. 32 GB Memory Map & Fast-Boot Storage** | `vmtouch` without `MAP_POPULATE` causes CPU page-fault storms; un-atomic cache writes corrupt `CreateGraphicsPipeline`; disabled GLCache forces cold compiles. | Invoked `taskset -c 5 vmtouch -dql` (`ulimit -l unlimited`, `vm.max_map_count=1048576`); trimmed `2M` HugePages to `2.0 GB` (`5.0 GB` Host Floor); enforced EROFS (`lz4hc,9`) `toram` + atomic `zstd -3` persistence for `EdenCache` & `nv_cache`. | `~0.75s` RAM boot; `+512 MB` driver/SPIR-V OOM safety margin; zero truncated shader-cache crashes. |
| **4. Audio & Input Phase-Locking** | Default USB URB batching and `125 Hz` HID polling add up to `8–16 ms` audio/input jitter; `128-sample` buffer exceeds `1 ms` USB SOF alignment. | Configured `snd-usb-audio nrpacks=1 lowlatency=1`, `usbcore.autosuspend=-1`, `96-frame` (`2.00 ms`) `S32_LE` ALSA period + micro-pitch PLL (`±0.005%`), `usbhid.jspoll=1`, and Core 5 `SCHED_FIFO 80` `/dev/hidraw*` `-1.5 ms` VBLANK latch. | Sub-`2.00 ms` L2-local DAC output; deterministic `1000 Hz` (`1 ms`) controller phase-lock ahead of VBLANK. |
| **5. Kernel, Driver & Buildroot Lock** | Upstream Batocera driver bumps (`590+`) drop Maxwell; external `PREEMPT_RT` patches drift; full Clang Buildroot breaks C packages. | Hard-pinned NVIDIA `580.*` legacy branch (`580.126.09`) on mainline Linux `6.12.x-rt` (`IGNORE_PREEMPT_RT_PRESENCE=1`); split GCC base OS / Clang 23+ `eden-ax` PGO build (`if (WIN32)`-gated ASIO); excluded `NVK`. | Guaranteed Maxwell P0 boost clocks (`1.2–1.4 GHz`), clean `nvidia.ko` builds, and `< 512 MB` rootfs.[cite: 14]

### ✅ Sprint 0 & Day-1 Hardware Validation Gates (`verify_ax_appliance.sh`)

Before executing Stage 1 PGO sweeps, Sprint 0 (Live USB Bench) and `verify_ax_appliance.sh` validate seven non-negotiable hardware invariants at boot[cite: 14]:

1. **Tickless Isolation & `mitigations=off`:** `/proc/interrupts` confirms zero `LOC` local timer ticks on Cores `0–4` (`nohz_full=0-4` + `rcu_nocbs=0-4`), `mitigations=off` active, and all kworker/SATA IRQs quarantined to Core 5 (`0x20`).
2. **Intel CAT MSR Probe (`rdmsr 0xc8f`):** Tests `rdmsr 0xc8f` on the i5-9600K to confirm Intel Cache Allocation Technology availability, automatically engaging `_MM_HINT_NTA` non-temporal prefetching on Core 5 (`0x20`) streaming reads if fused off on desktop Coffee Lake.
3. **Physical xHCI Bus Separation:** `lspci -nn` + `lsusb -t` verifies the HiBy FC3 DAC (`0x2fc6`) and Samsung FIT Plus (`MUF-64AB`) reside on distinct xHCI PCIe BDFs with HiBy IRQ pinned to `0x01`.
4. **Hybrid HugePages & Memory Ceiling:** `/proc/meminfo` confirms `6 × 1048576 kB` (`6.0 GB`) and `1024 × 2048 kB` (`2.0 GB`) HugePages locked, `512 MB` LZ4 `zram` active, and `>= 5.0 GB` Host Safety Floor free.
5. **Driver, Clock & Dedicated Transfer Queue Locks:** `nvidia-smi` confirms `580.*` legacy driver, persistence mode enabled (`-pm 1`), `pcie_aspm=off`, DDR4-3600 XMP + Symmetrical `x48` / Uncore `x45` active, and Vulkan 1.4 `VK_QUEUE_TRANSFER_BIT` + `5.00 GiB` `VkVramShield` initialized.
6. **Zero-Copy `dma_buf` Probe:** Runs a lightweight `vaExportSurfaceHandle` → `VkImageDrmFormatModifierListCreateInfoEXT` self-test between Intel UHD 630 and GTX 980 Ti.
7. **Zero-Xrun ALSA Lock:** Opens `hw:CARD=FC3,DEV=0` at `48 kHz` / `S32_LE` / `96 frames` under `SCHED_FIFO 99` on Core 0 and verifies `0` `EPIPE` xruns over a 10-second stress test.[cite: 14]

---

## 9. 🗺️ Phased Integration Roadmap, Timeframes & End-to-End PGO Build Checklist

### 9.1 📅 Cross-Project Integration Milestones (`v1.35 → v2.00`)

Timeframe estimates assume 1 experienced C++/Linux engineer working part-time (`15–20h/wk`) or full-time (`40h/wk`)[cite: 14]:

| Target Release | Backlog Phase | Scope & Key Deliverables | Part-Time (`15–20h/wk`) | Full-Time (`40h/wk`) | Primary Engineering Bottleneck |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`v1.35`** | Phase 3 (Memory, Async VRAM & GM200) | `[DONE]` `ax::vram` `5.00 GiB` async prune trigger + `VkVramShield` (`VK_QUEUE_TRANSFER_BIT` + Vulkan 1.4 `vkCmdSetEvent2`/`WaitEvents2`), dynamic `ax::topology` P-core/SMT `2:3:1` parser, batch SPSC audio ring; `[NEXT]` `ax_platform_shim.hpp` (`1G`/`2M` HugePages, micro-PLL ALSA) & `PGO_stage0LD` gate. | `1.5 – 2.5 weeks` | `1 week` | `96-frame` ALSA `hw:CARD=FC3` xrun tuning & live USB boot |
| **`v1.36`** | Phase 4 (Cross-GPU & Frame Gen) | Commit `vaapi_dmabuf_bridge.hpp` (`ModifierListCreateInfoEXT`), `256 MB BAR1` WC pool (`6.9`), `lsfg-vk 2.0.0+` (`5.35 GiB` cap), and `batocera-ax-external/` verification. | `4 – 6 weeks` | `2 – 3 weeks` | Intel `iHD` → NVIDIA `580.*` Maxwell `NV12 dma_buf` modifier alignment |
| **`v1.37`** | Phase 5 (Storage & MVP Appliance) | Add native GM200 `SHFL` reductions (`7.7`), build `< 512 MB` `6.12-rt` EROFS `toram` image, pass `verify_ax_appliance.sh`, execute RAM PGO sweeps, and ship Piccolo `v1.0`. | `3 – 5 weeks` | `1.5 – 2.5 weeks` | `6.12-rt` + NVIDIA `580.*` module build & EROFS blob pruning |
| **`v2.00`** | Phase 6 (Next-Gen Parity) | Run `720p`/`540p` `R8_UNORM` luma-only downscale on GTX 980 Ti before `dma_buf` export (`~75–85%` PCIe reduction) for Intel VME optical flow (`8.2`) + RP2040/ESP32-S3 sync dongle (`8.3`). | `6 – 10 weeks` | `3 – 5 weeks` | Custom USB HID phase-sync firmware & VME motion-vector extraction |
| **Total MVP** | `v1.35 → v1.37` | Production Bootable Samsung FIT Plus USB 3.0 Appliance | `8.5 – 13.5 weeks` | `4.5 – 6.5 weeks` | Cross-GPU `dma_buf` & `6.12-rt` Buildroot stabilization[cite: 14]

### 9.2 ✅ End-to-End USB Appliance Build & Two-Stage PGO Checklist

* **Stage 1 — BIOS, Silicon & Storage Foundation:**
  * Enable XMP (`DDR4-3600`), pin `VCCSA = 1.15–1.20 V` / `VCCIO = 1.15 V`, tighten `tREFI = 65535`, lock CPU ratios symmetrically (`x48` / `4.8 GHz` across all Cores `0–5` to avoid Vcore spikes, `x45` Uncore Ring, AVX Offset = `0`), and disable deep C-states.
  * Label internal SATA drive as `SwitchHDD` and format the Samsung FIT Plus 64 GB (`MUF-64AB/APC`) into `BATOCERA` (`4.0 GB FAT32`) and `SHARE` (`~55.6 GB ext4` with `-O ^has_journal`).
  * Connect the HiBy FC3 DAC and Samsung FIT Plus to physically separate xHCI PCIe controllers.
* **Stage 2 — Compile Stage 1 Instrumented Buildroot Image (`BR2_EXTERNAL`):**
  * Build `batocera-ax-external/` (`package/ax-sdk/`, `package/eden-ax/`, `package/cemu-latte-ax/`, `package/rmg-ax/`) with GCC base OS, Clang 23+ (`-fprofile-instr-generate -march=skylake -flto=thin`), Linux `6.12.x-rt` (`mitigations=off`), and pinned NVIDIA `580.126.09` legacy drivers.
  * Package the pruned `< 512 MB` EROFS (`-zlz4hc,9`) rootfs (plus `rootfs.erofs.prev` A/B fallback) and flash to the Samsung FIT Plus drive.
* **Stage 3 — Day-1 Quality Gate & Zero-Wear RAM PGO Sweeps:**
  * Boot via `toram` (`~0.75s` USB copy) and run `verify_ax_appliance.sh` to confirm `EXCELLENT_APPLIANCE_READY`.
  * Execute `3 × 15-minute` gameplay sweeps across representative titles, writing `.profraw` traces exclusively to `EdenCache` (`1.5 GB DDR4-3600 tmpfs`) and flushing atomically to `SHARE` via `K01piccolo-sync` on exit.
* **Stage 4 — Bake Stage 2 Production Release Image:**
  * Merge `.profraw` files into `eden.profdata` via `llvm-profdata`, recompile the L1i-linearized production binary (`-fprofile-use=eden.profdata`), rebuild the immutable `< 512 MB` EROFS image, and flash the final appliance release.[cite: 14]

---

## 10. ⚖️ Legal & Licensing Notice

* **Open-Source Compliance (`GPL-3.0-or-later` / `MIT` / `LGPL v3`):** All Eden Piccolo [AX] architectural specifications (`v0.6`), `ax-sdk` (`MIT`), C++20 Linux platform shims (`GPL-3.0-or-later`), and Batocera `BR2_EXTERNAL` Buildroot scripts are strictly non-commercial and open source.
* **BYO Licensed Assets:** This project distributes zero Nintendo firmware, cryptographic keys, commercial game ROMs, or proprietary `Lossless.dll` binaries. Users must supply their own legal hardware dumps and own a licensed copy of *Lossless Scaling* via Steam to enable `lsfg-vk` frame generation.[cite: 14]
