# Piccolo [AX] — Legal ROM & Firmware Placement Guide

In strict alignment with **The Silicon Preservation Society** policy and upstream emulator licenses, **Piccolo [AX] ships with zero copyrighted ROMs, BIOS files, or cryptographic keys**. You must legally own original game cartridges, discs, or arcade PCBs and dump your own files directly from your own hardware.

---

## Folder Paths & Supported Formats (`/userdata/roms/`)

Place your legally dumped game files into the corresponding folders on the `SHARE` partition (`/userdata/roms/`):

| System | Emulator `[AX]` | Target Folder | Supported File Extensions | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Nintendo Switch** | `Eden Espresso Wave [AX]` | `/userdata/roms/switch/` | `.nsp`, `.xci`, `.nca`, `.nro` | Place your dumped `prod.keys` and `title.keys` in `/userdata/system/configs/eden/keys/` (and optional external `SwitchHDD` drive). |
| **Nintendo Wii U** | `Cemu Latte [AX]` | `/userdata/roms/wiiu/` | `.wud`, `.wux`, `.wua`, `.rpx` | Place dumped `keys.txt` in `/userdata/system/configs/cemu/`. |
| **Nintendo 64** | `RMG-Mupen [AX]` | `/userdata/roms/n64/` | `.z64`, `.n64`, `.v64`, `.zip`, `.7z` | No external BIOS required; launches full-screen via `RMG --nogui`. |
| **Sega OutRun (Arcade)** | `Cannonball-OutRun [AX]` | `/userdata/roms/cannonball/` | `.game`, `.88` | Place your dumped **OutRun Revision B** MAME ROM files directly inside `/userdata/roms/cannonball/` alongside a dummy `outrun.game` trigger file so EmulationStation lists it. |

---

## Quick Verification
After copying your legally dumped files into `/userdata/roms/`, press **Start → Game Settings → Update Gamelists** in EmulationStation (or reboot) to see your titles appear automatically.
