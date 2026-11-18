# 🎛️ Piccolo [AX] — Batocera Linux Branch & Bare-Metal Console OS

**Piccolo `[AX]`** is the **Batocera Linux branch of [`Eden-Espresso-Wave-AX`](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX.git)**—engineered by **The Silicon Preservation Society** to transform proven `x86_64` PC hardware into a deterministic, `< 300 MB` bare-metal `toram` gaming console and keep it out of landfills.

Whereas `Eden-Espresso-Wave-AX` serves as the Windows 10/11 desktop development master, **Piccolo `[AX]`** adapts the Espresso Wave `[AX]` engine for `Linux 6.12-rt` (`PREEMPT_RT`), direct ALSA `SCHED_FIFO` audio, and Intel `iHD` VA-API `dma_buf` cross-GPU presentation, bundling the entire system into a zero-flash-wear EROFS image loaded directly into RAM.

---

## 🔗 The Silicon Preservation Society — Official Repository Network

*(See [REPO_TOPOLOGY.md](REPO_TOPOLOGY.md) for the full cross-host dependency and lineage diagram.)*

| Project | Role & Lineage | Canonical Repository | Base / Upstream |
| :--- | :--- | :--- | :--- |
| **Piccolo `[AX]`** | Batocera Linux Branch of Espresso Wave `[AX]` (`< 300 MB` `toram` OS) | [GitHub (`Piccolo-AX`)](https://github.com/galaxywarriordad/Piccolo-AX) | Branched from: [`Eden-Espresso-Wave-AX`](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX.git) · OS Base: [Batocera Linux](https://github.com/batocera-linux/batocera.linux) |
| **`ax-sdk`** | Shared C++20 Runtime Core (`libax_core` / `ax::core`) | [GitHub (`ax-sdk`)](https://github.com/galaxywarriordad/ax-sdk) | Dependency-Free C++20 Core |
| **Eden Espresso Wave `[AX]`** | Nintendo Switch Engine (Windows 10/11 Development Master) | [Eden Forgejo (`Eden-Espresso-Wave-AX`)](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX.git) | Upstream: [Eden](https://git.eden-emu.dev/eden-emu/eden/) |
| **Cemu Latte `[AX]`** | Nintendo Wii U (Win10/11 PGO + Batocera `[AX]`) | [GitHub (`Cemu-Latte-AX`)](https://github.com/galaxywarriordad/Cemu-Latte-AX) | Upstream: [Cemu](https://github.com/cemu-project/Cemu) |

---

## 🎯 Why Piccolo `[AX]` Exists

* **Keep Proven Hardware Out of Landfills:** Extracts console-grade frame pacing and audio precision from older `x86_64` PCs instead of forcing hardware upgrades.
* **Direct Lineage from Espresso Wave `[AX]`:** Inherits all core Switch engine optimizations from `Eden-Espresso-Wave-AX` and shared silicon primitives from `ax-sdk` (`v1.35.0`), replacing Windows-specific subsystems (FlexASIO, Win32 MMCSS, Media Foundation QSV) with native Linux real-time equivalents.
* **Deterministic Core Isolation (`2:3:1`):** Dedicated physical cores for real-time ALSA audio (`Core 0`), Vulkan command submission (`Core 1`), ARM64/PowerPC JIT execution (`Cores 2–4`), and background I/O + iGPU offloading (`Core 5`).
* **Real-Time Kernel & RAM Boot (`< 300 MB`):** Powered by `Linux 6.12-rt` (`isolcpus` / `nohz_full` / `rcu_nocbs`) and a pruned EROFS squashfs image loaded straight into RAM (`toram`) for instant startup and zero disk stutter.
* **Dual-GPU Silicon Offloading:** Pairs a discrete NVIDIA GPU (`580.*` drivers) with an Intel UHD iGPU (`iHD` VA-API / `VEBOX`) for hardware video decoding and zero-copy `dma_buf` frame presentation.

---

## 📚 Appliance & Architecture Specifications

* [Piccolo Linux Appliance Specification (`docs/PICOLLO_AX_SPEC.md`)](docs/PICOLLO_AX_SPEC.md)
* [Piccolo Implementation Plan (`docs/IMPLEMENTATION_PLAN.md`)](docs/IMPLEMENTATION_PLAN.md)
* [Unified Dual-Target Master Plan (`ax-sdk`)](https://github.com/galaxywarriordad/ax-sdk/blob/main/docs/UNIFIED_MASTER_PLAN.md)
* [Unified Multi-Architecture Silicon Topology Plan (`ax-sdk`)](https://github.com/galaxywarriordad/ax-sdk/blob/main/docs/SILICON_TOPOLOGY_PLAN.md)

---

## 📂 Repository Structure

```text
Piccolo-AX/
├── src/                                # Linux-adapted Eden Espresso Wave [AX] engine tree
├── CMakeLists.txt                      # Root CMake build wired to ax-sdk (v1.35.0)
├── batocera-ax-external/               # Buildroot BR2_EXTERNAL appliance overlay
│   ├── external.desc                   # PICCOLO_AX identifier
│   ├── Config.in                       # Appliance package & kernel options
│   ├── external.mk                     # Custom AX emulator & SDK makefiles
│   ├── configs/                        # Pruned < 300 MB piccolo_x86_64_defconfig
│   ├── board/piccolo/                  # linux.config (6.12-rt), grub.cfg, post-build/image scripts
│   ├── package/
│   │   ├── eden/                       # Builds Piccolo-AX Linux branch into Batocera rootfs
│   │   └── nvidia-driver-legacy580/    # Maxwell GM200 / Pascal 580.* driver package
│   └── rootfs-overlay/                 # S01piccolo-isolate, S02piccolo-hw, K01piccolo-sync, edenGenerator.py
├── docs/                               # EDEN_PICCOLO_SPEC.md appliance documentation
└── scripts/linux/                      # test_nv12_dmabuf.c, verify_ax_appliance.sh & fetch helpers
```

---

## 🤝 Contributing, License & Acknowledgements

* **Contributing:** See [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md) for Buildroot hygiene and hardware-ownership policies.
* **License & Acknowledgements:** Licensed under **GPL-3.0** ([LICENSE](LICENSE)). Branched from [Eden Espresso Wave `[AX]`](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX.git) and built on [Batocera Linux](https://github.com/batocera-linux/batocera.linux) and Buildroot. **Contains no proprietary console firmware, decryption keys, or games.**
