# Size & Build Discipline for Piccolo-AX

Piccolo-AX keeps its `toram` `EROFS` appliance image under **512 MB** by sharing runtime libraries, stripping debug symbols, and declaring explicit Buildroot dependencies[cite: 20, 21].

* **Shared `.so` Libraries Only:** Build Qt6 dynamically (`BR2_SHARED_LIBS=y`) so Eden, RMG, and Cemu share one copy of `libQt6Core.so`, `libQt6Gui.so`, and `libQt6Widgets.so` in RAM[cite: 21].
* **Strip Debug Symbols:** Enable `BR2_STRIP_strip=y` in `piccolo_x86_64_defconfig` to shrink Qt6 and emulator binaries by over 60% before `EROFS` compression[cite: 21].
* **Explicit Package Dependencies:** Declare `qt6base`, `qt6svg`, and `qt6websockets` in `*_DEPENDENCIES` across `rmg-ax.mk`, `eden-ax.mk`, and `cemu-latte-ax.mk` (keeping the total `EROFS` image under **512 MB**) so Buildroot compiles Qt6 first and exposes `Qt6Config.cmake` automatically to CMake.
