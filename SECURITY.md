# 🛡️ Security Policy & Appliance Privilege Notes

## ⚖️ Legal & Anti-Piracy Policy

**Piccolo `[AX]`** is a clean-room, open-source bare-metal Linux appliance overlay licensed under **GPL-3.0**.

* **Original Hardware Required:** Users **must legally own original Nintendo Switch and/or Wii U consoles** and dump their own system firmware, cryptographic keys, and legally purchased games from their own hardware.
* **Zero Proprietary Assets:** This repository contains no copyrighted console firmware, decryption keys, games, or proprietary NVIDIA/Intel binaries (driver packages are fetched at build time from official upstream sources via SHA256-verified `.hash` manifests).

---

## 🔒 Appliance Kernel & Privilege Architecture

Piccolo `[AX]` boots an immutable, read-only `toram` EROFS image from a USB 3.0 stick without modifying internal PC hard drives or Windows installations:

| Mechanism | Scope | Configuration / Privilege | Security & Stability Impact |
| :--- | :--- | :--- | :--- |
| **Read-Only `toram` RootFS** (`grub.cfg` / `post-image.sh`) | System RAM (`rootfs.erofs`) | Loaded into volatile RAM at boot | Eliminates USB flash wear and prevents persistent root filesystem tampering across reboots. |
| **CPU Isolation & IRQ Affinity** (`S01piccolo-isolate`, `S02piccolo-hw`) | `Linux 6.12-rt` boot init | Kernel `isolcpus` / `nohz_full` / `rcu_nocbs` + `cgroups v2` | Isolates `Core 0` (ALSA audio) and `Core 1` (Vulkan) from general kernel scheduling and steers PCIe/USB IRQs deterministically. |
| **Real-Time Scheduling (`SCHED_FIFO`) & HugePages** | Emulator processes (`eden`, `cemu`) | Appliance `CAP_SYS_NICE` / `vm.nr_hugepages` | Guarantees sub-millisecond audio and frame pacing without desktop privilege prompts. |

---

## 🔄 Safe Rollback & Host Isolation

* **Zero Host OS Modification:** Because Piccolo `[AX]` runs live from USB 3.0 in system RAM, unplugging the USB drive and rebooting immediately restores your PC's internal Windows or Linux installation untouched.

---

## 📬 Reporting a Vulnerability or Buildroot Issue

If you discover a privilege boundary issue, kernel configuration bug, or Buildroot packaging vulnerability in `Piccolo-AX`:

* Open an issue or private security advisory on **`galaxywarriordad/Piccolo-AX`** with reproduction steps, hardware details, and `verify_ax_appliance.sh` logs.
* Do **not** attach copyrighted game dumps, decryption keys, or firmware files to bug reports.
