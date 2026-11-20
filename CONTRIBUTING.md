# 🤝 Contributing to Piccolo [AX]

Thank you for your interest in **Piccolo `[AX]`**! Because this repository builds a `< 512 MB` bare-metal `toram` EROFS Linux appliance (`Linux 6.12-rt`, Batocera `BR2_EXTERNAL`, and `ax-sdk`), please review these guidelines before submitting issues or pull requests.

---

## ⚖️ Legal & Copyright Policy

In strict alignment with upstream **Batocera Linux**, **Eden**, **Cemu**, and **RMG**:
* **Original Hardware Required:** You **must own original Nintendo Switch, Wii U, and/or Nintendo 64 consoles** and dump your own system firmware, cryptographic keys (`prod.keys`, `title.keys`, `otp.bin`), and legally purchased games directly from your own hardware.
* **Zero Piracy Tolerance:** Any issue, pull request, commit, or log attachment referencing or containing copyrighted console firmware, decryption keys, ROMs/NSPs/XCIs/WUAs, or proprietary third-party binaries will be closed immediately.

---

## 🛠️ Buildroot & Real-Time Linux Standards

1. **Out-of-Tree Isolation (`BR2_EXTERNAL`):**
   * Keep all custom appliance recipes, kernel fragments, and rootfs overlays inside `batocera-ax-external/`. Never pollute upstream Batocera trees directly.
2. **Immutable Supply-Chain Pinning:**
   * • All external packages (package/eden-ax/eden-ax.mk, package/cemu-latte-ax/cemu-latte-ax.mk, package/rmg-ax/rmg-ax.mk, package/ax-sdk/ax-sdk.mk, package/nvidia-driver-legacy580/) must reference explicit commit SHAs or release tags accompanied by verified `.hash` SHA256 files.
3. **`PREEMPT_RT` & `toram` Footprint Discipline:**
   * Keep the root squashfs/EROFS payload strictly under `512 MB` so the entire OS boots cleanly into RAM without USB flash wear.
   * Never introduce blocking locks, swap partitions, or unpinned background daemons onto isolated real-time cores (`Core 0` ALSA `SCHED_FIFO` or `Core 1` Vulkan Worker).
4. **Cross-GPU & Audio Determinism:**
   * Preserve zero-copy `iHD` VA-API `dma_buf` handoffs between Intel UHD iGPUs and discrete NVIDIA GPUs, and keep USB xHCI / GPU interrupts pinned via `S01piccolo-isolate` and `S02piccolo-hw`.

---

## 🐛 Submitting Bug Reports & Appliance Logs

When opening an issue on **`galaxywarriordad/Piccolo-AX`**, please include:

1. **Hardware Topology:** CPU model (physical/logical cores), discrete GPU model, Intel iGPU model, USB 3.0 boot media, and USB DAC model.
2. **Appliance Verification Output:** Attach output from `scripts/linux/verify_ax_appliance.sh`, `/proc/cmdline`, and `/proc/interrupts`.
3. **Reproduction Steps:** Note which [AX] emulator (Eden-Espresso-Wave-AX, Cemu-Latte-AX, or RMG-Mupen-AX) and kernel boot flags were active.
