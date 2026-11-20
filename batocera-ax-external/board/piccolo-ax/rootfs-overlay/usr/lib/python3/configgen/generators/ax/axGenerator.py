#!/usr/bin/env python3
import hashlib
import os
import shutil
import signal
import subprocess
import sys
from pathlib import Path

try:
    from generators.Generator import Generator
    import Command
except ImportError:
    Generator = object
    Command = None

CACHE_PERSIST_DIR = Path("/userdata/cache")
EMU_TMPFS = Path("/dev/shm/emu_cache")
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
    EMU_TMPFS.mkdir(parents=True, exist_ok=True)
    NV_TMPFS.mkdir(parents=True, exist_ok=True)
    for prefix, target in (("emu", EMU_TMPFS), ("nv", NV_TMPFS)):
        archive = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst"
        if archive.exists():
            subprocess.run(["tar", "-I", "zstd", "-xf", str(archive), "-C", str(target)], check=False)


def flush_cache_atomic(title_id: str) -> None:
    CACHE_PERSIST_DIR.mkdir(parents=True, exist_ok=True)
    for prefix, src in (("emu", EMU_TMPFS), ("nv", NV_TMPFS)):
        if src.exists() and any(src.iterdir()):
            tmp_file = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst.tmp"
            final_file = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst"
            subprocess.run(["tar", "-I", "zstd -3", "-cf", str(tmp_file), "-C", str(src), "."], check=False)
            os.sync()
            tmp_file.replace(final_file)


def pin_rom_assets(rom_path: Path) -> subprocess.Popen | None:
    if not rom_path.exists() or not Path("/usr/bin/vmtouch").exists():
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
        try:
            pid = int(pid_str)
            subprocess.run(
                ["taskset", "-pc", "5", str(pid)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
            )
            os.kill(pid, sig)
        except (ValueError, ProcessLookupError):
            pass


def build_emulator_cmd(system_name: str, rom_path: Path) -> list[str]:
    if system_name == "wiiu":
        emu_args = ["/usr/bin/Cemu", "-f", "-g", str(rom_path)]
    elif system_name == "n64":
        emu_args = ["/usr/bin/RMG", "--nogui", "--fullscreen", str(rom_path)]
    else:
        emu_args = ["/usr/bin/eden-cli", "-f", "-g", str(rom_path)]
    if Path("/sys/fs/cgroup/eden.slice").exists():
        return ["cgexec", "-g", "cpuset:eden.slice", *emu_args]
    return emu_args


def launch_title(system_name: str, rom_path_str: str, title_id: str) -> int:
    rom_path = Path(rom_path_str)
    restore_cache(title_id)
    vmtouch_proc = pin_rom_assets(rom_path)

    env = os.environ.copy()
    env.setdefault("DISPLAY", ":0")
    env["QT_QPA_PLATFORM"] = "xcb"
    env["__GL_YIELD"] = "NOTHING"
    env["__GL_SYNC_TO_VBLANK"] = "1"
    env["__GL_MaxFramesAllowed"] = "1"
    env["__GL_SHADER_DISK_CACHE"] = "1"
    env["__GL_SHADER_DISK_CACHE_SKIP_CLEANUP"] = "1"
    env["__GL_SHADER_DISK_CACHE_PATH"] = str(NV_TMPFS)
    env["MESA_VK_WSI_PRESENT_MODE"] = "fifo"
    env["XDG_CACHE_HOME"] = str(EMU_TMPFS)

    toggle_emulationstation(signal.SIGSTOP)
    try:
        cmd = build_emulator_cmd(system_name, rom_path)
        proc = subprocess.run(cmd, env=env, check=False)
        return proc.returncode
    finally:
        if vmtouch_proc:
            vmtouch_proc.terminate()
            vmtouch_proc.wait(timeout=3)
        flush_cache_atomic(title_id)
        shutil.rmtree(EMU_TMPFS, ignore_errors=True)
        shutil.rmtree(NV_TMPFS, ignore_errors=True)
        toggle_emulationstation(signal.SIGCONT)


class AxGenerator(Generator):
    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        rom_path = Path(rom)
        title_id = hashlib.sha256(rom_path.name.encode("utf-8")).hexdigest()[:16]
        wrapper = [
            "/usr/bin/python3",
            __file__,
            system.name,
            str(rom_path),
            title_id,
        ]
        return Command.Command(array=wrapper)

    def getMouseMode(self, config, rom):
        return False


if __name__ == "__main__":
    if len(sys.argv) >= 4:
        sys.exit(launch_title(sys.argv[1], sys.argv[2], sys.argv[3]))
