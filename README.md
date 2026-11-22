# 🎛️ Piccolo \[AX\] — Batocera Linux Branch & Bare-Metal Console OS

**Piccolo `[AX]`** is the **Batocera Linux branch of [`Eden-Espresso-Wave-AX`](https://eden-emu.dev)**—engineered by **The Silicon Preservation Society** to transform proven `x86_64` PC hardware into a deterministic, `< 512 MB` bare-metal `toram` gaming console and keep it out of landfills.

Whereas `Eden-Espresso-Wave-AX` serves as the Windows 10/11 desktop development master, **Piccolo `[AX]`** adapts the Espresso Wave `[AX]` engine for `Linux 6.12-rt` (`PREEMPT_RT`), direct ALSA `SCHED_FIFO` audio, and Intel `iHD` VA-API `dma_buf` cross-GPU presentation, bundling the entire system into a zero-flash-wear EROFS image loaded directly into RAM.

---

## 🔗 The Silicon Preservation Society — Official Repository Network

*(See [REPO\_TOPOLOGY.md](http://REPO_TOPOLOGY.md) for the full cross-host dependency and lineage diagram.)*

| Project | Role & Lineage | Canonical Repository | Base / Upstream |
| :---- | :---- | :---- | :---- |
| **Piccolo `[AX]`** | Batocera Linux Branch of Espresso Wave `[AX]` (`< 512 MB` `toram` OS) | [GitHub (`Piccolo-AX`)](https://github.com) | Branched from: [`Eden-Espresso-Wave-AX`](https://eden-emu.dev) · OS Base: [Batocera Linux](https://github.com) |
| **`ax-sdk`** | Shared C++20 Runtime Core (`libax_core` / `ax::core`) | [GitHub (`ax-sdk`)](https://github.com) | Dependency-Free C++20 Core |
| **`Generation-X-AX`** | Unified Classic Engines `[AX]` Suite (N64, Mega Drive, OutRun, EDuke32, Frontier, Dreamcast, Atari ST) | [GitHub (`Generation-X-AX`)](https://github.com) | Upstream: `RMG`, `BlastEm`, `Cannonball`, `EDuke32`, `glfrontier`, `Flycast`, `Hatari` |
| **`piccolo-ax-desktop`** | Optional `< 35 MB` Native C/C++ Workbench & Diagnostics Layer | [GitHub (`piccolo-ax-desktop`)](https://github.com-desktop) | `LXQt`/`XFCE`, `Falkon`, `GrafX2`, `LibreSprite`, `mtPaint`, `AzPainter`, `GHex`, `CPU-X` |
| **Eden Espresso Wave `[AX]`** | Nintendo Switch Engine (Windows 10/11 Development Master) | [Eden Forgejo (`Eden-Espresso-Wave-AX`)](https://eden-emu.dev) | Upstream: [Eden](https://eden-emu.dev) |
| **Cemu Latte `[AX]`** | Nintendo Wii U (Win10/11 PGO \+ Batocera `[AX]`) | [GitHub (`Cemu-Latte-AX`)](https://github.com) | Upstream: [Cemu](https://github.com) |
| **`FLAC_AX`** | Deterministic `[AX]` Audio/Visual Studio (`ax_av_studio`) & Bit-Perfect ESS Sabre Player (`flac_ax`) | [GitHub (`FLAC_AX`)](https://github.com) | `libFLAC++` \+ Direct ALSA `SCHED_FIFO` \+ Akai MPK Mini MK3 \+ OpenGL HUD |

---

## 🎯 Why Piccolo `[AX]` Exists

* **Keep Proven Hardware Out of Landfills:** Extracts console-grade frame pacing and audio precision from older `x86_64` PCs instead of forcing hardware upgrades.  
* **Direct Lineage from Espresso Wave `[AX]`:** Inherits all core Switch engine optimizations from `Eden-Espresso-Wave-AX`, all 7 retro/arcade engines from `Generation-X-AX`, and shared silicon primitives from `ax-sdk` (`v1.36.1`), replacing Windows-specific subsystems (FlexASIO, Win32 MMCSS, Media Foundation QSV) with native Linux real-time equivalents.  
* **Deterministic Core Isolation (`2:3:1`):** Dedicated physical cores for real-time ALSA audio (`Core 0`), Vulkan/OpenGL command submission (`Core 1`), ARM64/PowerPC/MIPS/SH-4/68k/DSP execution (`Cores 2–4`), and background I/O, USB MIDI \+ iGPU offloading (`Core 5`).  
* **Real-Time Kernel & RAM Boot (`< 512 MB`):** Powered by `Linux 6.12-rt` (`isolcpus` / `nohz_full` / `rcu_nocbs`) and a pruned EROFS squashfs image loaded straight into RAM (`toram`) for instant startup and zero disk stutter.  
* **Unified Audio/Visual Studio (`FLAC_AX`):** Includes both the bit-perfect `44.1–384 kHz` `S32_LE` ESS Sabre player (`flac_ax`) and the live `2.00 ms` `ax_av_studio` synth/mixer/spectrum HUD with `/run/lock/ax-dac.lock` DAC handoff on emulator launch.  
* **Opt-In Native C/C++ Desktop Workbench (`piccolo-ax-desktop`):** Supports an optional `< 35 MB` zero-bloat desktop profile via `BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH` with persistent `SHARE` storage and zero impact on real-time console isolation.  
* **Dual-GPU Silicon Offloading:** Pairs a discrete NVIDIA GPU (`580.*` drivers) with an Intel UHD iGPU (`iHD` VA-API / `VEBOX`) for hardware video decoding and zero-copy `dma_buf` frame presentation.

---

## 📚 Appliance & Architecture Specifications

* [Piccolo-AX Architecture Topology & Reference Implementation (`docs/PICCOLO_AX_ARCHITECTURE.md`)](http://docs/PICCOLO_AX_ARCHITECTURE.md)  
* [Piccolo Linux Appliance Specification (`docs/PICOLLO_AX_SPEC.md`)](http://docs/PICOLLO_AX_SPEC.md)  
* [Piccolo Implementation Plan (`docs/IMPLEMENTATION_PLAN.md`)](http://docs/IMPLEMENTATION_PLAN.md)  
* [Unified Dual-Target Master Plan (`ax-sdk`)](https://github.com/blob/main/docs/UNIFIED_MASTER_PLAN.md)  
* [Unified Multi-Architecture Silicon Topology Plan (`ax-sdk`)](https://github.com/blob/main/docs/SILICON_TOPOLOGY_PLAN.md)

---

## 📂 Repository Structure

```
Piccolo-AX/
├── src/                                # Linux-adapted Eden Espresso Wave [AX] engine tree
├── CMakeLists.txt                      # Root CMake build wired to ax-sdk (v1.36.1)
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
│       └── flac-ax/                    # Bit-perfect ESS Sabre player & A/V Studio package
├── docs/                               # PICCOLO_AX_ARCHITECTURE.md, PICOLLO_AX_SPEC.md & IMPLEMENTATION_PLAN.md
└── scripts/linux/                      # test_nv12_dmabuf.c, verify_ax_appliance.sh & fetch helpers
```

---

## 🤝 Contributing, License & Acknowledgements

* **Contributing:** See [CONTRIBUTING.md](http://CONTRIBUTING.md) and [SECURITY.md](http://SECURITY.md) for Buildroot hygiene and hardware-ownership policies.  
* **License & Acknowledgements:** Licensed under **GPL-3.0** ([LICENSE](http://LICENSE)). Branched from [Eden Espresso Wave `[AX]`](https://eden-emu.dev) and built on [Batocera Linux](https://github.com) and Buildroot. **Contains no proprietary console firmware, decryption keys, or games.**
