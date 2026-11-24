# **🎛️ Piccolo \[AX\] — Batocera Linux Branch & Bare-Metal Console OS**

**Piccolo `[AX]`** is the **Batocera Linux branch of [`Eden-Espresso-Wave-AX`](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX)**—engineered by **The Silicon Preservation Society** to transform proven `x86_64` PC hardware into a deterministic, `< 512 MB` bare-metal `toram` gaming console and keep it out of landfills.

Whereas `Eden-Espresso-Wave-AX` serves as the Windows 10/11 desktop development master, **Piccolo `[AX]`** adapts the Espresso Wave `[AX]` engine for `Linux 6.12-rt` (`PREEMPT_RT`), direct ALSA `SCHED_FIFO` audio, and Intel `iHD` VA-API `dma_buf` cross-GPU presentation, bundling the entire system into a zero-flash-wear EROFS image loaded directly into RAM.

# **🔗 The Silicon Preservation Society — Official 9-Repository Network**

*(See [`REPO_TOPOLOGY.md`](https://github.com/galaxywarriordad/ax-sdk/blob/main/REPO_TOPOLOGY.md) for the full cross-host dependency diagram and the **Policy-in-SDK / Adapter-in-Consumer** boundary contract.)*

| Project | Role & Lineage | Canonical Repository | Base / Upstream |
| :---- | :---- | :---- | :---- |
| **Piccolo `[AX]`** | Batocera Linux Branch of Espresso Wave `[AX]` (`< 512 MB` `toram` OS) | [GitHub (`Piccolo-AX`)](https://github.com/galaxywarriordad/Piccolo-AX) | Branched from: [`Eden-Espresso-Wave-AX`](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX) · OS Base: [Batocera Linux](https://github.com/batocera-linux/batocera.linux) |
| **`ax-sdk`** | Shared C++20 Runtime Core (`libax_core` / `ax::core`) | [GitHub (`ax-sdk`)](https://github.com/galaxywarriordad/ax-sdk) | Dependency-Free C++20 Core (`v1_36_2`) |
| **Piccolo-2go** | Deterministic `aarch64` Handheld OS (`RK3326` `1:2:1`) | [GitHub (`Piccolo-2go`)](https://github.com/galaxywarriordad/Piccolo-2go) | Buildroot `aarch64` (BATLEXP G350 & R36S) |
| **`Generation-X-AX`** | Unified Classic Engines `[AX]` Suite (N64, Mega Drive, OutRun, EDuke32, Frontier, Dreamcast, Atari ST) | [GitHub (`Generation-X-AX`)](https://github.com/galaxywarriordad/Generation-X-AX) | Upstream: `RMG`, `BlastEm`, `Cannonball`, `EDuke32`, `glfrontier`, `Flycast`, `Hatari` |
| **`piccolo-ax-desktop`** | Optional `< 42 MB` Tier A Native C/C++ Workbench & Diagnostics Layer | [GitHub (`piccolo-ax-desktop`)](https://github.com/galaxywarriordad/piccolo-ax-desktop) | `LXQt`/`XFCE`, `Falkon`, `GrafX2`, `LibreSprite`, `mtPaint`, `AzPainter`, `GHex`, `CPU-X` |
| **Eden Espresso Wave `[AX]`** | Nintendo Switch Engine (Windows 10/11 Development Master) | [Eden Forgejo (`Eden-Espresso-Wave-AX`)](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX) | Upstream: [Eden](https://eden-emu.dev) |
| **Cemu Latte `[AX]`** | Nintendo Wii U (Win10/11 PGO \+ Batocera `[AX]`) | [GitHub (`Cemu-Latte-AX`)](https://github.com/galaxywarriordad/Cemu-Latte-AX) | Upstream: [Cemu](https://github.com/cemu-project/Cemu) |
| **`FLAC_AX`** | Deterministic `[AX]` Audio/Visual Studio (`ax_av_studio`), Tracker Player (`libopenmpt`), Video Upscaler & Espresso TUI | [GitHub (`FLAC_AX`)](https://github.com/galaxywarriordad/FLAC_AX.git) | `libFLAC++` \+ `libopenmpt` \+ Direct ALSA `SCHED_FIFO` \+ Akai MPK Mini MK3 \+ OpenGL HUD |
| **Amiberry `[AX]`** | Commodore Amiga 500 / 1200 / CD32 Engine | [GitHub (`Amiberry-AX`)](https://github.com/galaxywarriordad/Amiberry-AX.git) | Upstream: [Amiberry](https://github.com/BlitterStudio/amiberry.git) |

# **🎯 Why Piccolo `[AX]` Exists**

* **Keep Proven Hardware Out of Landfills:** Extracts console-grade frame pacing and audio precision from older `x86_64` PCs instead of forcing hardware upgrades.  
* **Direct Lineage from Espresso Wave `[AX]`:** Inherits core Switch engine optimizations from `Eden-Espresso-Wave-AX`, retro/arcade engines from `Generation-X-AX`, and shared silicon primitives from `ax-sdk` (`v1_36_2`), replacing Windows-specific subsystems with native Linux real-time equivalents.  
* **Deterministic Core Isolation (`2:3:1`):** Dedicated physical cores for real-time ALSA audio (`Core 0`), Vulkan/OpenGL command submission (`Core 1`), guest CPU/DSP execution (`Cores 2–4`), and background I/O, USB MIDI \+ iGPU offloading (`Core 5`).  
* **Real-Time Kernel & RAM Boot (`< 512 MB`):** Powered by `Linux 6.12-rt` (`isolcpus` / `nohz_full` / `rcu_nocbs`) and a pruned EROFS image loaded straight into RAM (`toram`) for fast startup and reduced storage contention.  
* **Unified Audio/Visual Studio (`FLAC_AX`):** Supports both the bit-perfect `44.1–384 kHz` `S32_LE` ESS Sabre player (`flac_ax`) and the `2.00 ms` `ax_av_studio` synth/mixer/spectrum HUD with `/run/lock/ax-dac.lock` DAC handoff on emulator launch.  
* **Opt-In Native C/C++ Desktop Workbench (`piccolo-ax-desktop`):** Supports an optional `< 42 MB` Tier A desktop profile via `BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH` with persistent `SHARE` storage and isolation from real-time appliance cores.  
* **Dual-GPU Silicon Offloading:** Pairs a discrete NVIDIA GPU (`580.*` drivers) with an Intel UHD iGPU (`iHD` VA-API / `VEBOX`) for hardware video decoding and zero-copy `dma_buf` frame presentation.

# **📚 Appliance & Architecture Specifications**

* [Piccolo-AX Architecture Topology & Reference Implementation](http://docs/PICCOLO_AX_ARCHITECTURE.md)  
* [Piccolo Linux Appliance Specification](http://docs/PICCOLO_AX_SPEC.md)  
* [Piccolo Implementation Plan](http://docs/IMPLEMENTATION_PLAN.md)  
* [Unified Dual-Target Master Plan (`ax-sdk`)](https://github.com/galaxywarriordad/ax-sdk/blob/main/docs/UNIFIED_MASTER_PLAN.md)  
* [Unified Multi-Architecture Silicon Topology Plan (`ax-sdk`)](https://github.com/galaxywarriordad/ax-sdk/blob/main/docs/SILICON_TOPOLOGY_PLAN.md)

# **📂 Repository Structure**

```
Piccolo-AX/
├── piccolo-ax-build.sh        # Build & appliance/desktop staging helper
├── batocera-ax-external/      # Buildroot BR2_EXTERNAL appliance overlay
│   ├── external.desc          # PICCOLO_AX identifier
│   ├── Config.in              # Appliance package, desktop & kernel options
│   ├── external.mk            # Custom AX emulator, SDK & opt-in desktop makefiles
│   ├── configs/               # Pruned < 512 MB piccolo_x86_64_defconfig
│   ├── board/piccolo-ax/      # grub.cfg, limine.conf, post-build.sh, post-image.sh
│   │   └── rootfs-overlay/    # S01piccolo-isolate, S02piccolo-hw, K01piccolo-sync, ax-grow-share.sh, ax-mode-cli, verify_ax_appliance.sh, axGenerator.py
│   └── package/
│       ├── ax-sdk/            # Shared C++20 silicon core package
│       ├── eden-ax/           # Nintendo Switch [AX] package
│       ├── cemu-latte-ax/     # Nintendo Wii U [AX] package
│       ├── rmg-ax/            # Nintendo 64 (RMG-Mupen [AX]) package
│       ├── blastem-ax/        # Sega Mega Drive [AX] package
│       ├── cannonball-ax/     # Sega OutRun [AX] package
│       ├── frontier-ax/       # Frontier: Elite II [AX] package
│       ├── flycast-ax/        # Sega Dreamcast / NAOMI / Atomiswave [AX] package
│       ├── hatari-ax/         # Atari ST / STE / TT / Falcon [AX] package
│       ├── amiberry-ax/       # Commodore Amiga 500 / 1200 / CD32 [AX] package
│       └── flac-ax/           # Bit-perfect ESS Sabre player, tracker player, A/V Studio, upscaler & Espresso TUI package
├── docs/                      # PICCOLO_AX_ARCHITECTURE.md, PICCOLO_AX_SPEC.md & IMPLEMENTATION_PLAN.md
└── scripts/linux/             # test_nv12_dmabuf.c, verify_ax_appliance.sh & fetch helpers
```

# **🌐 9-Repository Silicon Preservation Society Ecosystem**

This repository is part of **The Silicon Preservation Society** (`[AX]`) ecosystem—a nine-repository bare-metal hardware preservation stack built around **Policy-in-SDK / Adapter-in-Consumer** separation:

1. **Shared Silicon SDK (GitHub):** [`galaxywarriordad/ax-sdk`](https://github.com/galaxywarriordad/ax-sdk.git) — Shared dependency-free C++20 deterministic hardware runtime (`ax::core` / `v1_36_2`), dynamic Intel SMT / AMD CCX / `RK3326` `1:2:1` topology resolver, platform shims, and master architecture specs.  
2. **Linux USB Console & A/V Appliance (GitHub):** [`galaxywarriordad/Piccolo-AX`](https://github.com/galaxywarriordad/Piccolo-AX.git) — Standalone `< 512 MB` `toram` EROFS Batocera / Buildroot `Linux 6.12-rt` `x86_64` appliance (`batocera-ax-external`) with direct ALSA `SCHED_FIFO` and `iHD` VA-API `dma_buf`.  
3. **Linux Handheld Appliance (GitHub):** [`galaxywarriordad/Piccolo-2go`](https://github.com/galaxywarriordad/Piccolo-2go.git) — Deterministic Buildroot `aarch64` (`RK3326` `1:2:1`) retro handheld OS for **BATLEXP G350** and **R36S**.  
4. **Optional Desktop Tier (GitHub):** [`galaxywarriordad/piccolo-ax-desktop`](https://github.com/galaxywarriordad/piccolo-ax-desktop.git) — On-demand C/C++ LXQt/X11 desktop workbench (`< 42 MB` Tier A budget) isolated on housekeeping cores.  
5. **Commodore Amiga Engine (GitHub):** [`galaxywarriordad/Amiberry-AX`](https://github.com/galaxywarriordad/Amiberry-AX.git) — Deterministic Commodore Amiga 500 / 1200 / CD32 engine linked against `ax-sdk` (`v1_36_2`).  
6. **Bare-Metal Audio & A/V Engine (GitHub):** [`galaxywarriordad/FLAC_AX`](https://github.com/galaxywarriordad/FLAC_AX.git) — RAM-resident bit-perfect audio player, `ax_av_studio` MIDI/DSP synth workstation, `ax_video_upscaler` stream pipeline, and `ax_appliance_tui`.  
7. **Retro Multi-System Engine (GitHub):** [`galaxywarriordad/Generation-X-AX`](https://github.com/galaxywarriordad/Generation-X-AX.git) — Deterministic multi-console `[AX]` adapter suite powering `RMG`, `BlastEm`, `Cannonball`, `Frontier`, `Flycast`, `Hatari`, and `EDuke32`.  
8. **Wii U Engine (GitHub):** [`galaxywarriordad/Cemu-Latte-AX`](https://github.com/galaxywarriordad/Cemu-Latte-AX.git) — Deterministic Nintendo Wii U (Latte GPU) `[AX]` engine powered by `ax::core` (`v1_36_2`).  
9. **Main Switch Engine Fork (Forgejo):** [`galaxywarriordad/Eden-Espresso-Wave-AX`](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX.git) — Deterministic Nintendo Switch fork tuned for `ax::core` core topology, Vulkan telemetry, and low-latency audio, kept aligned with upstream (`eden-emu/eden`) for frictionless PR cherry-picks.

For full core-pinning tables (`2:3:1` and `1:2:1`), cross-repository data flow, and architectural specifications, see [ax-sdk/REPO\_TOPOLOGY.md](https://github.com/galaxywarriordad/ax-sdk/blob/main/REPO_TOPOLOGY.md) and [`ax-sdk/docs/ECOSYSTEM_ARCHITECTURE.md`](https://github.com/galaxywarriordad/ax-sdk/blob/main/docs/ECOSYSTEM_ARCHITECTURE.md).

# **🤝 Contributing, License & Acknowledgements**

* **Contributing:** See [CONTRIBUTING.md](http://CONTRIBUTING.md) and [SECURITY.md](http://SECURITY.md) for Buildroot hygiene and hardware-ownership policies.  
* **License & Acknowledgements:** Licensed under **GPL-3.0** ([LICENSE](http://LICENSE)). Branched from [Eden Espresso Wave `[AX]`](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX) and built on [Batocera Linux](https://github.com/batocera-linux/batocera.linux) and Buildroot. **Contains no proprietary console firmware, decryption keys, or copyrighted ROM/game assets.** Users must supply legally dumped files from hardware they own.

