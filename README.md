# 🎛️ Piccolo [AX] — Bare-Metal Real-Time Console OS

A deterministic, `< 300 MB` bare-metal Linux console appliance built on **Batocera Linux** (`BR2_EXTERNAL`)—engineered by **The Silicon Preservation Society** to keep proven PC hardware out of landfills.

Piccolo `[AX]` strips away desktop bloat and runs directly in system RAM (`toram`), transforming classic multi-core desktops (such as Intel Coffee Lake + NVIDIA Maxwell/Pascal + Intel UHD iGPU) into a dedicated, zero-jitter gaming console for `[AX]` emulators.

---

## 🔗 The Silicon Preservation Society — Official Repository Network

*(See [REPO_TOPOLOGY.md](REPO_TOPOLOGY.md) for the full cross-host dependency diagram.)*

| Project | Role | Canonical Repository | Base / Upstream |
| :--- | :--- | :--- | :--- |
| **Piccolo `[AX]`** | `< 300 MB` Bare-Metal Linux Console OS | [GitHub (`Piccolo-AX`)](https://github.com/galaxywarriordad/Piccolo-AX) | Base: [Batocera Linux](https://github.com/batocera-linux/batocera.linux) |
| **`ax-sdk`** | Shared C++20 Runtime Core (`libax_core`) | [GitHub (`ax-sdk`)](https://github.com/galaxywarriordad/ax-sdk) | Dependency-Free C++20 Core |
| **Eden Espresso Wave `[AX]`** | Nintendo Switch (Windows 10/11 PGO + Linux) | [Eden Forgejo (`Eden-Espresso-Wave-AX`)](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX.git) | Upstream: [Eden](https://git.eden-emu.dev/eden-emu/eden/) |
| **Cemu Latte `[AX]`** | Nintendo Wii U (Win10/11 PGO + Batocera `[AX]`) | [GitHub (`Cemu-Latte-AX`)](https://github.com/galaxywarriordad/Cemu-Latte-AX) | Upstream: [Cemu](https://github.com/cemu-project/Cemu) |

---

## 🎯 Why Piccolo `[AX]` Exists

* **Keep Proven Hardware Out of Landfills:** Extracts console-grade frame pacing and audio precision from older `x86_64` PCs instead of forcing hardware upgrades.
* **Deterministic Core Isolation (`2:3:1`):** Dedicated physical cores for real-time audio (`Core 0`), GPU command submission (`Core 1`), JIT execution (`Cores 2–4`), and background I/O + iGPU offloading (`Core 5`).
* **Real-Time Kernel & RAM Boot (`< 300 MB`):** Powered by `Linux 6.12-rt` and a pruned EROFS squashfs image loaded straight into RAM for instant startup and zero disk stutter.
* **Dual-GPU Silicon Offloading:** Pairs a discrete NVIDIA GPU (`580.*` drivers) with an Intel UHD iGPU (`iHD` VA-API / `VEBOX`) for hardware video decoding and zero-copy `dma_buf` frame presentation.
* **Bit-Perfect USB DAC Audio:** Direct `2.00 ms` ALSA `SCHED_FIFO` ring buffer routing with hardware IRQ pinning for zero crackles or dropouts.

---

## 📚 Appliance & Architecture Specifications

* [Piccolo Linux Appliance Specification (`docs/EDEN_PICCOLO_SPEC.md`)](docs/EDEN_PICCOLO_SPEC.md)
* [Unified Dual-Target Master Plan (`ax-sdk`)](https://github.com/galaxywarriordad/ax-sdk/blob/main/docs/UNIFIED_MASTER_PLAN.md)
* [Unified Multi-Architecture Silicon Topology Plan (`ax-sdk`)](https://github.com/galaxywarriordad/ax-sdk/blob/main/docs/SILICON_TOPOLOGY_PLAN.md)

---

## 📂 Repository Structure

```text
Piccolo-AX/
├── batocera-ax-external/               # Buildroot BR2_EXTERNAL appliance tree
│   ├── external.desc                   # PICCOLO_AX identifier
│   ├── Config.in                       # Appliance package & kernel options
│   ├── external.mk                     # Custom AX emulator & SDK makefiles
│   ├── configs/                        # Pruned < 300 MB piccolo_x86_64_defconfig
│   ├── board/piccolo/                  # linux.config (6.12-rt), grub.cfg, post-build/image scripts
│   ├── package/
│   │   ├── ax-sdk/                     # Pinned ax-sdk Buildroot package
│   │   ├── eden/                       # Pinned Eden-Espresso-Wave-AX Buildroot package
│   │   └── nvidia-driver-legacy580/    # Maxwell GM200 / Pascal 580.* driver package
│   └── rootfs-overlay/                 # S01piccolo-isolate, S02piccolo-hw, K01piccolo-sync, edenGenerator.py
├── docs/                               # EDEN_PICCOLO_SPEC.md appliance documentation
└── scripts/linux/                      # test_nv12_dmabuf.c, verify_ax_appliance.sh & fetch helpers
```

---

## 🤝 Contributing, License & Acknowledgements

* **Contributing:** See [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md) for Buildroot hygiene and hardware-ownership policies.
* **License & Acknowledgements:** Licensed under **GPL-3.0** ([LICENSE](LICENSE)). Built on [Batocera Linux](https://github.com/batocera-linux/batocera.linux) and Buildroot. **Contains no proprietary console firmware, decryption keys, or games.**[cite: 32]
