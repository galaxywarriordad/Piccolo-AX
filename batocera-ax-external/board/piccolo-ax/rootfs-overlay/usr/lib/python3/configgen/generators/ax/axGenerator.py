#!/usr/bin/env python3
import os
import shutil
import signal
import subprocess
from pathlib import Path

CACHE_PERSIST_DIR = Path("/userdata/cache")
EDEN_TMPFS = Path("/dev/shm/eden_cache")
NV_TMPFS = Path("/dev/shm/nv_cache")
HOST_SAFETY_FLOOR_BYTES = 5 * 1024**3
MAX_VMTOUCH_BYTES = int(17.5 * 1024**3)


def get_available_ram_bytes() -> int:
    with open("/proc/meminfo", "r", encoding="utf-8") as f:
        for line in f:
            if line.startswith("MemAvailable:"):
                return int(line.split()[1]) * 1024
    return 0


def restore_cache(title_id: str) -> None:
    EDEN_TMPFS.mkdir(parents=True, exist_ok=True)
    NV_TMPFS.mkdir(parents=True, exist_ok=True)
    for prefix, target in (("eden", EDEN_TMPFS), ("nv", NV_TMPFS)):
        archive = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst"
        if archive.exists():
            subprocess.run(["tar", "-I", "zstd", "-xf", str(archive), "-C", str(target)], check=False)


def flush_cache_atomic(title_id: str) -> None:
    CACHE_PERSIST_DIR.mkdir(parents=True, exist_ok=True)
    for prefix, src in (("eden", EDEN_TMPFS), ("nv", NV_TMPFS)):
        if src.exists() and any(src.iterdir()):
            tmp_file = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst.tmp"
            final_file = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst"
            subprocess.run(["tar", "-I", "zstd -3", "-cf", str(tmp_file), "-C", str(src), "."], check=False)
            os.sync()
            tmp_file.replace(final_file)


def pin_rom_assets(rom_path: Path) -> subprocess.Popen | None:
    if not rom_path.exists():
        return None
    avail = get_available_ram_bytes()
    budget = min(MAX_VMTOUCH_BYTES, max(0, avail - HOST_SAFETY_FLOOR_BYTES))
    if budget < 256 * 1024**2:
        return None
    max_mb = budget // (1024 * 1024)
    return subprocess.Popen(
        ["taskset", "-c", "5", "vmtouch", "-dql", f"-m{max_mb}M", str(rom_path)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def toggle_emulationstation(sig: int) -> None:
    res = subprocess.run(["pidof", "emulationstation"], capture_output=True, text=True, check=False)
    for pid_str in res.stdout.strip().split():
        pid = int(pid_str)
        subprocess.run(["taskset", "-pc", "5", str(pid)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
        os.kill(pid, sig)


def launch_title(emulator_bin: str, rom_path_str: str, title_id: str) -> int:
    rom_path = Path(rom_path_str)
    restore_cache(title_id)
    vmtouch_proc = pin_rom_assets(rom_path)

    env = os.environ.copy()
    env["__GL_YIELD"] = "NOTHING"
    env["__GL_SHADER_DISK_CACHE"] = "1"
    env["__GL_SHADER_DISK_CACHE_PATH"] = str(NV_TMPFS)

    toggle_emulationstation(signal.SIGSTOP)
    try:
        proc = subprocess.run([emulator_bin, str(rom_path)], env=env, check=False)
        return proc.returncode
    finally:
        if vmtouch_proc:
            vmtouch_proc.terminate()
        flush_cache_atomic(title_id)
        shutil.rmtree(EDEN_TMPFS, ignore_errors=True)
        shutil.rmtree(NV_TMPFS, ignore_errors=True)
        toggle_emulationstation(signal.SIGCONT)
