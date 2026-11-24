# **📜 Third-Party Software & Open-Source License Notices (`Piccolo-AX`)**

**Piccolo `[AX]`** (`galaxywarriordad/Piccolo-AX`) is an out-of-tree Buildroot (`BR2_EXTERNAL`) bare-metal Linux console and audio/visual appliance overlay licensed under **GPL-3.0** (`LICENSE`). It builds upon and packages the following upstream open-source projects and hardware driver components:

# **1\. Core Operating System, Kernel & Bootloader Components**

| Component | Upstream Repository / Source | License | Role in Piccolo-AX |
| :---- | :---- | :---- | :---- |
| **Batocera Linux** | `https://github.com/batocera-linux/batocera.linux` | `GPL-2.0` / `GPL-3.0` | Base Buildroot distribution framework and EmulationStation front-end |
| **Buildroot** | `https://buildroot.org` | `GPL-2.0` | Cross-compilation toolchain, root filesystem assembly, and `BR2_EXTERNAL` infrastructure |
| **Linux Kernel (`6.12-rt`)** | `https://kernel.org` | `GPL-2.0-only` | Real-time (`PREEMPT_RT`, `NO_HZ_FULL`, `rcu_nocbs`) `x86_64` kernel |
| **Limine Bootloader** | `https://github.com/limine-bootloader/limine` | `BSD-2-Clause` | Multi-mode UEFI/BIOS boot manager (`limine.conf`) |
| **GNU GRUB** | `https://www.gnu.org/software/grub/` | `GPL-3.0` | Primary UEFI boot chain (`grub.cfg`) with A/B `rootfs.erofs.prev` rollback |
| **EROFS Utils (`mkfs.erofs`)** | `https://git.kernel.org/pub/scm/linux/kernel/git/xiang/erofs-utils.git` | `GPL-2.0` / `Apache-2.0` | Immutable `lz4hc,9` `< 512 MB` `toram` root filesystem image builder |
| **Mesa 3D & Intel `iHD` Media Driver** | `https://mesa3d.org` / `https://github.com/intel/media-driver` | `MIT` | Intel UHD Graphics 630 VA-API / `VEBOX` video decode and `dma_buf` export |

# **2\. Shared `[AX]` Runtime & Packaged Emulation / Audio Engines**

| Package (batocera-ax-external/package/) | Upstream / Base Project | License | Role in Piccolo-AX |
| :---- | :---- | :---- | :---- |
| **`ax-sdk`** (`ax::core` `v1_36_2`) | `https://github.com/galaxywarriordad/ax-sdk` | `MIT` | Dependency-free C++20 `2:3:1` topology, HugeTLB fastmem, VRAM shield & telemetry core |
| **`eden-ax`** | `Eden-Espresso-Wave-AX` / `https://git.eden-emu.dev/eden-emu/eden/` | `GPL-3.0` | Nintendo Switch `[AX]` emulator |
| **`cemu-latte-ax`** | `Cemu-Latte-AX` / `https://github.com/cemu-project/Cemu` | `MPL-2.0` | Nintendo Wii U (Latte GPU) `[AX]` emulator |
| **`flac-ax`** | `FLAC_AX` (`libFLAC++`, `libopenmpt`, `ALSA`, `SDL2`) | `MIT (libFLAC++: BSD-3-Clause, libopenmpt: BSD-3-Clause)` | Bit-perfect `S32_LE` / `DoP` audio player, tracker player, `ax_av_studio`, `ax_video_upscaler`, and `ax_appliance_tui` |
| **`amiberry-ax`** | `Amiberry-AX` / `https://github.com/BlitterStudio/amiberry` | `GPL-3.0` | Commodore Amiga 500 / 1200 / CD32 `[AX]` emulator |
| **`rmg-ax`** | `Generation-X-AX` / `Rosalie's Mupen GUI` (`RMG`) | `GPL-3.0` | Nintendo 64 `[AX]` emulator |
| **`blastem-ax`** | `Generation-X-AX` / `BlastEm` | `GPL-3.0` | Sega Mega Drive `[AX]` emulator |
| **`cannonball-ax`** | `Generation-X-AX` / `CannonBall` | `GPL-3.0 (custom non-commercial clauses upstream)` | Sega OutRun `[AX]` engine |
| **`frontier-ax`** | `Generation-X-AX` / `glfrontier` | `GPL-2.0 / GPL-3.0` | Frontier: Elite II `[AX]` engine |
| **`flycast-ax`** | `Generation-X-AX` / `Flycast` | `GPL-2.0` | Sega Dreamcast / NAOMI / Atomiswave `[AX]` emulator |
| **`hatari-ax`** | `Generation-X-AX` / `Hatari` | `GPL-2.0` | Atari ST / STE / TT / Falcon `[AX]` emulator |

# **3\. Proprietary Driver & User-Supplied Content Policy**

* **NVIDIA Linux Legacy Driver (`580.*`):** Fetched exclusively at Buildroot compile time from official NVIDIA release servers via SHA256-verified `.hash` manifests; no proprietary driver blobs are redistributed inside this Git repository.  
* **No Copyrighted Firmware, Keys, or ROMs:** `Piccolo-AX` ships with zero console firmware, cryptographic keys (`prod.keys`, `title.keys`, `otp.bin`), or game ROMs/ISOs. Users must supply legally dumped files from hardware they personally own.
