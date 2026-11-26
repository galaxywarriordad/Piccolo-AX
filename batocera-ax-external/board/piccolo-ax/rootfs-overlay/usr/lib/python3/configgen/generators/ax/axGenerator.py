MIN_FREE_CACHE_BYTES = 256 * 1024 * 1024


def _dir_size_bytes(path: Path) -> int:
    total = 0
    for root, _, files in os.walk(path):
        for name in files:
            try:
                total += (Path(root) / name).stat().st_size
            except OSError:
                pass
    return total


def _has_sufficient_cache_space(cache_dir: Path, required_bytes: int) -> bool:
    try:
        st = os.statvfs(cache_dir)
    except OSError:
        return False
    avail_bytes = st.f_bavail * st.f_frsize
    return avail_bytes >= required_bytes


def _is_valid_zstd_archive(archive: Path) -> bool:
    if not archive.exists() or archive.stat().st_size == 0:
        return False
    res = subprocess.run(
        ["zstd", "-t", "-q", str(archive)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    return res.returncode == 0


def restore_cache(title_id: str) -> None:
    EMU_TMPFS.mkdir(parents=True, exist_ok=True)
    NV_TMPFS.mkdir(parents=True, exist_ok=True)
    for prefix, target in (("emu", EMU_TMPFS), ("nv", NV_TMPFS)):
        archive = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst"
        prev_archive = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst.prev"
        chosen: Path | None = None
        if _is_valid_zstd_archive(archive):
            chosen = archive
        elif _is_valid_zstd_archive(prev_archive):
            chosen = prev_archive
        if chosen is not None:
            subprocess.run(
                ["tar", "-I", "zstd", "-xf", str(chosen), "-C", str(target)],
                check=False,
            )


def flush_cache_atomic(title_id: str) -> None:
    CACHE_PERSIST_DIR.mkdir(parents=True, exist_ok=True)
    for prefix, src in (("emu", EMU_TMPFS), ("nv", NV_TMPFS)):
        if not (src.exists() and any(src.iterdir())):
            continue
        raw_bytes = _dir_size_bytes(src)
        needed_bytes = max(MIN_FREE_CACHE_BYTES, raw_bytes // 2)
        if not _has_sufficient_cache_space(CACHE_PERSIST_DIR, needed_bytes):
            continue

        tmp_file = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst.tmp"
        prev_file = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst.prev"
        final_file = CACHE_PERSIST_DIR / f"{prefix}_{title_id}.tar.zst"

        pack_res = subprocess.run(
            ["tar", "-I", "zstd -3", "-cf", str(tmp_file), "-C", str(src), "."],
            check=False,
        )
        if pack_res.returncode != 0 or not _is_valid_zstd_archive(tmp_file):
            tmp_file.unlink(missing_ok=True)
            continue

        if final_file.exists():
            try:
                os.replace(final_file, prev_file)
            except OSError:
                pass

        tmp_file.replace(final_file)
        os.sync()
