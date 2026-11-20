# Three Size-Saving Rules for Piccolo-AX

# 1. Shared .so Libraries Only: 
Build Qt6 dynamically (BR2_SHARED_LIBS=y, which is Buildroot's default) so Eden, RMG, and Cemu all share one copy of libQt6Core.so, libQt6Gui.so, and libQt6Widgets.so in RAM.

# 2. Strip Debug Symbols & Translations: 
Ensure BR2_STRIP_strip=y is enabled in piccolo_x86_64_defconfig—Qt6 binaries shrink by over 60% once debug symbols are stripped, and EROFS (lz4 or zstd) compresses them further.

# 3. Declare qt6base as a Dependency in Each Package: 
In rmg-ax.mk, eden-ax.mk, and cemu-latte-ax.mk, add qt6base qt6svg qt6websockets to *_DEPENDENCIES (keeps total EROFS image under 512 MB) so Buildroot compiles Qt6 first and exposes Qt6Config.cmake automatically to CMake.
