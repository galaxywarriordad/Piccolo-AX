# 🎛️ Piccolo [AX] — Bare-Metal Real-Time Console OS

A deterministic, `< 300 MB` bare-metal Linux console appliance built on **Batocera Linux** (`BR2_EXTERNAL`)—engineered by **The Silicon Preservation Society** to keep proven PC hardware out of landfills.

Piccolo `[AX]` strips away desktop bloat and runs directly in system RAM (`toram`), transforming classic multi-core desktops (such as Intel Coffee Lake + NVIDIA Maxwell/Pascal + Intel UHD iGPU) into a dedicated, zero-jitter gaming console for `[AX]` emulators.

---

## 🔗 The Silicon Preservation Society — Official Repository Network

| Project | Role | Primary Repository | Mirror / Upstream |
| :--- | :--- | :--- | :--- |
| **Piccolo `[AX]`** | `< 300 MB` Bare-Metal Linux Console OS | [GitHub (`Piccolo-AX`)](https://github.com) | Base: [Batocera Linux](https://github.com) |
| **`ax-sdk`** | Shared C++20 Runtime Core (`libax_core`) | [GitHub (`ax-sdk`)](https://github.com) | Dependency-Free Core |
| **Eden Espresso Wave `[AX]`** | Nintendo Switch (Windows 10 Bridge + Linux) | [Eden Forgejo](https://eden-emu.dev) | Mirror: [GitHub](https://github.com) · Upstream: [Eden](https://eden-emu.dev) |
| **Cemu Latte `[AX]`** | Nintendo Wii U (Win10 PGO + Batocera `[AX]`) | [GitHub (`Cemu-Latte-AX`)](https://github.com) | Upstream: [Cemu](https://github.com) |

---

## 🎯 Why Piccolo `[AX]` Exists

* **Keep Proven Hardware Out of Landfills:** Extracts console-grade frame pacing and audio precision from older x86_64 PCs instead of forcing hardware upgrades.
* **Deterministic Core Isolation (`2:3:1`):** Dedicated physical cores for real-time audio (`Core 0`), GPU command submission (`Core 1`), JIT execution (`Cores 2–4`), and background I/O + iGPU offloading (`Core 5`).
* **Real-Time Kernel & RAM Boot (`< 300 MB`):** Powered by `Linux 6.12-rt` and a pruned EROFS squashfs image loaded straight into RAM for instant startup and zero disk stutter.
* **Dual-GPU Silicon Offloading:** Pairs a discrete NVIDIA GPU (`580.*` drivers) with an Intel UHD iGPU (`QSV` / `VEBOX`) for hardware video decoding and texture processing.
* **Bit-Perfect USB DAC Audio:** Direct `2.00 ms` ALSA ring buffer routing with hardware IRQ pinning for zero crackles or dropouts.

---

## 📂 Repository Structure

```text
Piccolo-AX/
├── batocera-ax-external/   # Buildroot BR2_EXTERNAL appliance tree
│   ├── external.desc       # PICCOLO_AX identifier
│   ├── Config.in           # Appliance package & kernel options
│   ├── external.mk         # Custom AX emulator & SDK makefiles
│   ├── configs/            # Pruned < 300 MB x86_64 defconfig & Linux 6.12-rt fragment
│   ├── package/            # ax-sdk, eden-ax, and cemu-ax Buildroot packages
│   └── board/piccolo-ax/   # Rootfs overlay (S01piccolo-isolate, ALSA, IRQ rules)
├── patches/                # Pinned upstream Batocera Linux patches
└── scripts/                # Build orchestrator & verify_ax_appliance.sh gate
```

---

## 🤝 License & Acknowledgements

Licensed under **GPL-3.0** (`LICENSE`). Built on [Batocera Linux](https://github.com) and Buildroot. Contains no proprietary console firmware, keys, or games.

