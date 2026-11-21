## 🌐 AX Ecosystem: Multi-Repository Topology & Lineage

The **AX Project** separates shared low-level C++20 silicon abstractions (`ax-sdk`) from platform-, emulator-, and workbench-specific repositories so upstream rebases stay clean while hardware isolation logic remains unified across Windows 10/11 and bare-metal Linux.

```text
                    +-------------------------------------------------------+

                    |                        ax-sdk                         |
                    |        https://github.com     |
                    |  Shared C++20 Silicon Core, Dynamic SMT/CCX Topology, |
                    |  Platform Shims, Telemetry Schemas & Master Specs     |
                    +-------------------------------------------------------+
                       /            |               |              \
       CMake FetchContent   CMake FetchContent  CMake FetchContent  Runtime / Telemetry
                     /              |               |                \
                    v               v               v                 v
+-----------------------+ +-------------------+ +------------------+ +-----------------------+

| Eden-Espresso-Wave-AX | |    Piccolo-AX     | |  Cemu-Latte-AX   | |   Generation-X-AX     |
| (Forgejo — Switch)    | | (GitHub — OS)     | | (GitHub — Wii U) | | (GitHub — 7 Classics) |
| Win10/11 Master,      | | < 512 MB toram    | | Wii U / Latte    | | RMG, BlastEm, OutRun, |
| LLVM 23 PGO, QSV      | | 6.12-rt Appliance | | Powered by ax    | | EDuke32, Frontier,    |
+-----------------------+ +-------------------+ +------------------+ | Flycast & Hatari      |
                                    ^                                +-----------------------+
                                    | Optional BR2_EXTERNAL Layer
                          +-------------------+

                          | piccolo-ax-desktop|
                          | (GitHub — <35 MB) |
                          | C/C++ Workbench   |
                          +-------------------+
```

### Repository Breakdown & Lineage

| Repository | Host & Canonical URL | Primary Role & Lineage |
| :--- | :--- | :--- |
| **`ax-sdk`** | **GitHub:** [`galaxywarriordad/ax-sdk`](https://github.com) | Shared, zero-dependency C++20 silicon library (`libax_core` / `ax::core`), dynamic Intel SMT / AMD CCX topology resolver, Win32/Linux platform shims, and cross-project master specs. |
| **`Eden-Espresso-Wave-AX`** | **Forgejo:** [`galaxywarriordad/Eden-Espresso-Wave-AX`](https://eden-emu.dev) | **Windows 10/11 Switch Engine Master** — Direct fork of upstream Eden hosted on Forgejo for frictionless PR cherry-picks; features LLVM `clang-cl` 23+ 3-stage PGO, FlexASIO/WASAPI Exclusive audio, Intel QSV offload, and Maxwell GM200 VRAM shields. |
| **`Piccolo-AX`** | **GitHub:** [`galaxywarriordad/Piccolo-AX`](https://github.com) | **Batocera Linux Branch of `Eden-Espresso-Wave-AX`** — Adapts the Espresso Wave `[AX]` engine for bare-metal Linux (`Linux 6.12-rt`, direct ALSA `SCHED_FIFO`, `iHD` VA-API `dma_buf`) and packages all `[AX]` engines via `batocera-ax-external/` into a `< 512 MB` `toram` EROFS USB 3.0 console appliance. |
| **`Generation-X-AX`** | **GitHub:** [`galaxywarriordad/Generation-X-AX`](https://github.com) | **Unified Classic Engines `[AX]` Suite** — Consolidates 7 classic 1985–1998 engines (`RMG` N64, `BlastEm` Mega Drive, `Cannonball` OutRun, `EDuke32`, `Frontier: Elite II`, `Flycast` Dreamcast/NAOMI, and `Hatari` Atari ST) behind `ax_retro_bridge` (`ax::core`). |
| **`Cemu-Latte-AX`** | **GitHub:** [`galaxywarriordad/Cemu-Latte-AX`](https://github.com) | **Nintendo Wii U (Latte GPU) AX Fork** — Integrates `ax::core` for deterministic physical-core isolation, MMCSS/ALSA audio prioritization, and hardware IRQ/VRAM discipline across Windows 10/11 and `Piccolo-AX`. |
| **`piccolo-ax-desktop`** | **GitHub:** [`galaxywarriordad/piccolo-ax-desktop`](https://github.com-desktop) | **Optional `< 35 MB` C/C++ Desktop Workbench** — Pluggable `BR2_EXTERNAL` overlay providing `LXQt`/`XFCE`, `Falkon`, `GrafX2`, `LibreSprite`, `mtPaint`, `AzPainter`, `GHex`, and `CPU-X` with `SHARE` persistence. |
| **`FLAC_AX`** | **GitHub:** [`galaxywarriordad/FLAC_AX`](https://github.com) | **Bare-Metal ESS Sabre Audio Appliance** — Dedicated `libFLAC++` + direct ALSA `SCHED_FIFO` playback runtime. |

### Cross-Repository Dependency & Merge Flow

* **Shared Silicon Core (`ax-sdk`):** `Eden-Espresso-Wave-AX`, `Piccolo-AX`, `Cemu-Latte-AX`, and `Generation-X-AX` all consume `ax-sdk` (`v1.36.1`) as a pinned CMake dependency (`ax::core`), inheriting identical core-pinning, HugeTLB/Large-Page fastmem, and audio ring primitives without duplicating C++20 code.
* **Unified Appliance Assembly (`Piccolo-AX`):** `batocera-ax-external/` pulls `Eden-Espresso-Wave-AX`, `Cemu-Latte-AX`, and all `Generation-X-AX` engine targets into a single immutable `rootfs.erofs` image—with optional `piccolo-ax-desktop` workbench layering enabled via `BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH`.
