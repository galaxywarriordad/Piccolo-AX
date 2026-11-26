import shutil
import subprocess
from pathlib import Path

MIN_RESERVE_BYTES = 64 * 1024 * 1024


def _dir_size_bytes(path: Path) -> int:
    total = 0
    for item in path.rglob("*"):
        if item.is_file():
            try:
                total += item.stat().st_size
            except OSError:
                pass
    return total


def _is_valid_zst(archive: Path) -> bool:
    if not archive.exists() or archive.stat().st_size == 0:
        return False
    res = subprocess.run(
        ["zstd", "-t", "-q", str(archive)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    return res.returncode == 0


def cleanup_stale_cache_tmp(title_id: str) -> None:
    if not CACHE_PERSIST_DIR.exists():
        return
    for prefix in ("emu", "nv"):
        for stale in CACHE_PERSIST_DIR.glob(f"{prefix}_{title_id}.tar.zst.tmp*"):
            stale.unlink(missing_ok=True)


def restore_cache(title_id: str) -> None:
    EMU_TMPFS.mkdir(parents=True, exist_ok=True)
    NV_TMPFS.mkdir(parents=True, exist_ok=True)
    cleanup_stale_cache_tmp(title_id)

    for prefix, target in (("emu", EMU_TMPFS), ("nv", NV_TMPFS)):
        primary = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst"
        backup = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst.prev"

        chosen: Path | None = None
        if _is_valid_zst(primary):
            chosen = primary
        elif _is_valid_zst(backup):
            chosen = backup

        if chosen is not None:
            subprocess.run(
                ["tar", "-I", "zstd", "-xf", str(chosen), "-C", str(target)],
                check=False,
            )


def flush_cache_atomic(title_id: str) -> None:
    CACHE_PERSIST_DIR.mkdir(parents=True, exist_ok=True)
    cleanup_stale_cache_tmp(title_id)

    for prefix, src in (("emu", EMU_TMPFS), ("nv", NV_TMPFS)):
        if not src.exists() or not any(src.iterdir()):
            continue

        src_bytes = _dir_size_bytes(src)
        free_bytes = shutil.disk_usage(CACHE_PERSIST_DIR).free
        req_bytes = ((src_bytes * 5) // 4) + MIN_RESERVE_BYTES
        if free_bytes < req_bytes:
            continue

        tmp_file = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst.tmp.{os.getpid()}"
        final_file = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst"
        prev_file = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst.prev"

        try:
            res = subprocess.run(
                ["tar", "-cf", "-", "-C", str(src), "."],
                stdout=subprocess.PIPE,
                check=False,
            )
            if res.returncode != 0 or not res.stdout:
                tmp_file.unlink(missing_ok=True)
                continue

            zstd_res = subprocess.run(
                ["zstd", "-3", "-T1", "-q", "-o", str(tmp_file)],
                input=res.stdout,
                check=False,
            )
            if zstd_res.returncode != 0 or not _is_valid_zst(tmp_file):
                tmp_file.unlink(missing_ok=True)
                continue

            if _is_valid_zst(final_file):
                shutil.copy2(final_file, prev_file)

            tmp_file.replace(final_file)
            os.sync()
        except OSError:
            tmp_file.unlink(missing_ok=True)
