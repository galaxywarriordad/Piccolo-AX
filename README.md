# 🎛️ Piccolo [AX] — Batocera Linux Branch & Bare-Metal Console OS

**Piccolo `[AX]`** is the **Batocera Linux branch of [`Eden-Espresso-Wave-AX`](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX)**—engineered by **The Silicon Preservation Society** to transform proven `x86_64` PC hardware into a deterministic, `< 512 MB` bare-metal `toram` gaming console and keep it out of landfills.

Whereas `Eden-Espresso-Wave-AX` serves as the Windows 10/11 desktop development master, **Piccolo `[AX]`** adapts the Espresso Wave `[AX]` engine for `Linux 6.12-rt` (`PREEMPT_RT`), direct ALSA `SCHED_FIFO` audio, and Intel `iHD` VA-API `dma_buf` cross-GPU presentation, bundling the entire system into a zero-flash-wear EROFS image loaded directly into RAM.

---

## 🔗 The Silicon Preservation Society — Official Repository Network

*(See [`REPO_TOPOLOGY.md`](https://github.com/galaxywarriordad/ax-sdk/blob/main/REPO_TOPOLOGY.md) for the full cross-host dependency and lineage diagram.)*

| Project | Role & Lineage | Canonical Repository | Base / Upstream |
| :--- | :--- | :--- | :--- |
| **Piccolo `[AX]`** | Batocera Linux Branch of Espresso Wave `[AX]` (`< 512 MB` `toram` OS) | [GitHub (`Piccolo-AX`)](https://github.com/galaxywarriordad/Piccolo-AX) | Branched from: [`Eden-Espresso-Wave-AX`](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX) · OS Base: [Batocera Linux](https://github.com/batocera-linux/batocera.linux) |
| **`ax-sdk`** | Shared C++20 Runtime Core (`libax_core` / `ax::core`) | [GitHub (`ax-sdk`)](https://github.com/galaxywarriordad/ax-sdk) | Dependency-Free C++20 Core |
| **`Generation-X-AX`** | Unified Classic Engines `[AX]` Suite (N64, Mega Drive, OutRun, EDuke32, Frontier, Dreamcast, Atari ST) | [GitHub (`Generation-X-AX`)](https://github.com/galaxywarriordad/Generation-X-AX) | Upstream: `RMG`, `BlastEm`, `Cannonball`, `EDuke32`, `glfrontier`, `Flycast`, `Hatari` |
| **`piccolo-ax-desktop`** | Optional `< 35 MB` Native C/C++ Workbench & Diagnostics Layer | [GitHub (`piccolo-ax-desktop`)](https://github.com/galaxywarriordad/piccolo-ax-desktop) | `LXQt`/`XFCE`, `Falkon`, `GrafX2`, `LibreSprite`, `mtPaint`, `AzPainter`, `GHex`, `CPU-X` |
| **Eden Espresso Wave `[AX]`** | Nintendo Switch Engine (Windows 10/11 Development Master) | [Eden Forgejo (`Eden-Espresso-Wave-AX`)](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX) | Upstream: [Eden](https://eden-emu.dev) |
| **Cemu Latte `[AX]`** | Nintendo Wii U (Win10/11 PGO + Batocera `[AX]`) | [GitHub (`Cemu-Latte-AX`)](https://github.com/galaxywarriordad/Cemu-Latte-AX) | Upstream: [Cemu](https://github.com/cemu-project/Cemu) |
| **`FLAC_AX`** | Deterministic `[AX]` Audio/Visual Studio (`ax_av_studio`), Tracker Player (`libopenmpt`), Video Upscaler & Espresso TUI | [GitHub (`FLAC_AX`)](https://github.com/galaxywarriordad/FLAC_AX.git) | `libFLAC++` + `libopenmpt` + Direct ALSA `SCHED_FIFO` + Akai MPK Mini MK3 + OpenGL HUD |
| **Amiberry `[AX]`** | Commodore Amiga 500 / 1200 / CD32 Engine | [GitHub (`Amiberry-AX`)](https://github.com/galaxywarriordad/Piccolo-AX/tree/main/batocera-ax-external/package/amiberry-ax) | Upstream: [Amiberry](https://github.com/BlitterStudio/amiberry.git) |

---

## 🎯 Why Piccolo `[AX]` Exists

* **Keep Proven Hardware Out of Landfills:** Extracts console-grade frame pacing and audio precision from older `x86_64` PCs instead of forcing hardware upgrades.
* **Direct Lineage from Espresso Wave `[AX]`:** Inherits core Switch engine optimizations from `Eden-Espresso-Wave-AX`, retro/arcade engines from `Generation-X-AX`, and shared silicon primitives from `ax-sdk` (`v1_36_2`), replacing Windows-specific subsystems with native Linux real-time equivalents.
* **Deterministic Core Isolation (`2:3:1`):** Dedicated physical cores for real-time ALSA audio (`Core 0`), Vulkan/OpenGL command submission (`Core 1`), guest CPU/DSP execution (`Cores 2–4`), and background I/O, USB MIDI + iGPU offloading (`Core 5`).
* **Real-Time Kernel & RAM Boot (`< 512 MB`):** Powered by `Linux 6.12-rt` (`isolcpus` / `nohz_full` / `rcu_nocbs`) and a pruned EROFS image loaded straight into RAM (`toram`) for fast startup and reduced storage contention.
* **Unified Audio/Visual Studio (`FLAC_AX`):** Supports both the bit-perfect `44.1–384 kHz` `S32_LE` ESS Sabre player (`flac_ax`) and the `2.00 ms` `ax_av_studio` synth/mixer/spectrum HUD with `/run/lock/ax-dac.lock` DAC handoff on emulator launch.
* **Opt-In Native C/C++ Desktop Workbench (`piccolo-ax-desktop`):** Supports an optional `< 35 MB` desktop profile via `BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH` with persistent `SHARE` storage and isolation from real-time appliance cores.
* **Dual-GPU Silicon Offloading:** Pairs a discrete NVIDIA GPU (`580.*` drivers) with an Intel UHD iGPU (`iHD` VA-API / `VEBOX`) for hardware video decoding and zero-copy `dma_buf` frame presentation.

---

## 📚 Appliance & Architecture Specifications

* [Piccolo-AX Architecture Topology & Reference Implementation](docs/PICCOLO_AX_ARCHITECTURE.md)
* [Piccolo Linux Appliance Specification](docs/PICCOLO_AX_SPEC.md)
* [Piccolo Implementation Plan](docs/IMPLEMENTATION_PLAN.md)
* [Unified Dual-Target Master Plan (`ax-sdk`)](https://github.com/galaxywarriordad/ax-sdk/blob/main/docs/UNIFIED_MASTER_PLAN.md)
* [Unified Multi-Architecture Silicon Topology Plan (`ax-sdk`)](https://github.com/galaxywarriordad/ax-sdk/blob/main/docs/SILICON_TOPOLOGY_PLAN.md)

---

## 📂 Repository Structure

```text
Piccolo-AX/
├── piccolo-ax-build.sh                 # Build & appliance/desktop staging helper
├── batocera-ax-external/               # Buildroot BR2_EXTERNAL appliance overlay
│   ├── external.desc                   # PICCOLO_AX identifier
│   ├── Config.in                       # Appliance package, desktop & kernel options
│   ├── external.mk                     # Custom AX emulator, SDK & opt-in desktop makefiles
│   ├── configs/                        # Pruned < 512 MB piccolo_x86_64_defconfig
│   ├── board/piccolo-ax/               # grub.cfg, limine.conf, post-build.sh, post-image.sh
│   │   └── rootfs-overlay/             # S01piccolo-isolate, S02piccolo-hw, K01piccolo-sync, ax-grow-share.sh, ax-mode-cli, verify_ax_appliance.sh, axGenerator.py
│   └── package/
│       ├── ax-sdk/                     # Shared C++20 silicon core package
│       ├── eden-ax/                    # Nintendo Switch [AX] package
│       ├── cemu-latte-ax/              # Nintendo Wii U [AX] package
│       ├── rmg-ax/                     # Nintendo 64 (RMG-Mupen [AX]) package
│       ├── blastem-ax/                 # Sega Mega Drive [AX] package
│       ├── cannonball-ax/              # Sega OutRun [AX] package
│       ├── frontier-ax/                # Frontier: Elite II [AX] package
│       ├── flycast-ax/                 # Sega Dreamcast / NAOMI / Atomiswave [AX] package
│       ├── hatari-ax/                  # Atari ST / STE / TT / Falcon [AX] package
│       ├── amiberry-ax/                # Commodore Amiga 500 / 1200 / CD32 [AX] package
│       └── flac-ax/                    # Bit-perfect ESS Sabre player, tracker player, A/V Studio, upscaler & Espresso TUI package
├── docs/                               # PICCOLO_AX_ARCHITECTURE.md, PICCOLO_AX_SPEC.md & IMPLEMENTATION_PLAN.md
└── scripts/linux/                      # test_nv12_dmabuf.c, verify_ax_appliance.sh & fetch helpers
```

---

## 🌐 Silicon Preservation Society Ecosystem

### Core Repositories (8)

1. **Shared Silicon SDK (GitHub):** [`galaxywarriordad/ax-sdk`](https://github.com/galaxywarriordad/ax-sdk.git) — Shared dependency-free C++20 deterministic hardware runtime (`ax::sdk` / `v1_36_2`), dynamic Intel SMT / AMD CCX topology resolver, platform shims, and master architecture specs.
2. **Linux USB Console & A/V Appliance (GitHub):** [`galaxywarriordad/Piccolo-AX`](https://github.com/galaxywarriordad/Piccolo-AX.git) — Standalone `< 512 MB` `toram` EROFS Batocera / Buildroot `Linux 6.12-rt` `x86_64` appliance (`batocera-ax-external`) with direct ALSA `SCHED_FIFO` and `iHD` VA-API `dma_buf`.
3. **Linux Handheld Appliance (GitHub):** [`galaxywarriordad/Piccolo-2go`](https://github.com/galaxywarriordad/Piccolo-2go.git) — Deterministic Buildroot `aarch64` (`RK3326` `1:2:1`) retro handheld OS for **BATLEXP G350** and **R36S**.
4. **Optional Desktop Tier (GitHub):** [`galaxywarriordad/piccolo-ax-desktop`](https://github.com/galaxywarriordad/piccolo-ax-desktop.git) — On-demand C/C++ LXQt/X11 desktop workbench (`< 35 MB` budget).
5. **Commodore Amiga Engine (GitHub):** [`galaxywarriordad/Amiberry-AX`](https://github.com/galaxywarriordad/Amiberry-AX.git) — Deterministic Commodore Amiga 500 / 1200 / CD32 engine linked against `ax-sdk`.
6. **Bare-Metal Audio & A/V Engine (GitHub):** [`galaxywarriordad/FLAC_AX`](https://github.com/galaxywarriordad/FLAC_AX.git) — RAM-resident bit-perfect audio player, `ax_av_studio` MIDI/DSP synth workstation, and `ax_video_upscaler` stream pipeline.
7. **Retro Multi-System Engine (GitHub):** [`galaxywarriordad/Generation-X-AX`](https://github.com/galaxywarriordad/Generation-X-AX.git) — Deterministic multi-console `[AX]` integration across `Flycast` and `RMG`.
8. **Wii U Engine (GitHub):** [`galaxywarriordad/Cemu-Latte-AX`](https://github.com/galaxywarriordad/Cemu-Latte-AX.git) — Deterministic Nintendo Wii U (Latte GPU) AX engine powered by `ax::sdk`.

### Sister & Downstream Forks

- **Main Switch Engine Fork (Forgejo):** [`galaxywarriordad/Eden-Espresso-Wave-AX`](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX.git) — Deterministic Nintendo Switch fork tuned for `ax::sdk` core topology, Vulkan telemetry, and low-latency audio, kept aligned with upstream for frictionless PR cherry-picks.
- **Upstream Ecosystem Hub (Forgejo):** [`eden-emu/eden`](https://git.eden-emu.dev/eden-emu/eden/) — Upstream Eden Switch emulator reference repository.

---

## 🤝 Contributing, License & Acknowledgements

* **Contributing:** See [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md) for Buildroot hygiene and hardware-ownership policies.
* **License & Acknowledgements:** Licensed under **GPL-3.0** ([LICENSE](LICENSE)). Branched from [Eden Espresso Wave `[AX]`](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX) and built on [Batocera Linux](https://github.com/batocera-linux/batocera.linux) and Buildroot. **Contains no proprietary console firmware, decryption keys, or games.**
