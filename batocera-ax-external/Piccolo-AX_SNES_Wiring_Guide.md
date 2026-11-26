# Wiring SNES (`genx-snes-ax`) into `Generation-X-AX` and `Piccolo-AX` (`ax-sdk v1_36_2`)

This guide shows how to wire the SNES adapter (`ax_snes_adapter.hpp` / `ax_snes_adapter.cpp`, `ax_engine.ini` `[snes]` \+ `[snes.presets.*]`, and `ax-snes-launch.sh`) into **`Generation-X-AX`** and package it as `genx-snes-ax` inside **`Piccolo-AX`** (`batocera-ax-external/package/genx-snes-ax/`).

---

## 1\. Wiring into `Generation-X-AX`

Place the adapter files under `Generation-X-AX/src/snes/` alongside your existing classic engine adapters (`RMG`, `BlastEm`, `Cannonball`, `EDuke32`, `Frontier: Elite II`, `Flycast`, `Hatari`) and link against `ax-sdk` (`v1_36_2` / `ax::core`).

### `Generation-X-AX/src/snes/CMakeLists.txt`

```
add_library(ax_genx_snes STATIC
    ax_snes_adapter.cpp
)

target_include_directories(ax_genx_snes
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

if(TARGET ax::core)
    target_link_libraries(ax_genx_snes PUBLIC ax::core)
    target_compile_definitions(ax_genx_snes PUBLIC GENX_SNES_HAS_AX_SDK=1)
endif()

target_compile_features(ax_genx_snes PUBLIC cxx_std_20)
```

### `Generation-X-AX/src/snes/genx_snes_main.cpp`

```c
#include "ax_snes_adapter.hpp"

#include <csignal>
#include <cstdlib>
#include <iostream>
#include <string>

namespace {
volatile std::sig_atomic_t g_stop_flag = 0;

void HandleSignal(int signum) {
    (void)signum;
    g_stop_flag = 1;
}

std::string ParseArg(int argc, char** argv, const std::string& flag) {
    for (int i = 1; i + 1 < argc; ++i) {
        if (flag == argv[i]) {
            return argv[i + 1];
        }
    }
    return {};
}
} // namespace

int main(int argc, char** argv) {
    const std::string config_path = ParseArg(argc, argv, "--config").empty()
        ? "/userdata/system/piccolo-ax/ax_engine.ini"
        : ParseArg(argc, argv, "--config");
    const std::string rom_path = ParseArg(argc, argv, "--rom");
    const std::string preset_override = ParseArg(argc, argv, "--preset");

    if (rom_path.empty()) {
        std::cerr << "[genx-snes-ax] Missing required --rom <path> argument.\n";
        return 2;
    }

    std::signal(SIGINT, HandleSignal);
    std::signal(SIGTERM, HandleSignal);
    std::signal(SIGUSR1, HandleSignal);

    ax::genx::snes::AxSnesAdapter adapter;
    if (!adapter.Initialize(config_path, rom_path)) {
        std::cerr << "[genx-snes-ax] Initialization failed.\n";
        return 1;
    }

    if (!preset_override.empty()) {
        std::cerr << "[genx-snes-ax] Preset override requested: " << preset_override << "\n";
    }

    if (!adapter.StartSession()) {
        std::cerr << "[genx-snes-ax] Failed starting deterministic SNES session.\n";
        return 1;
    }

    // Main loop placeholder: hand off staged ROM/SRAM to bsnes/ares SNES core
    // while pacing Core 0 ALSA S32_LE ring fill via ComputeRateGuardPpm().
    while (!g_stop_flag) {
        const int ppm = adapter.ComputeRateGuardPpm(50);
        (void)ppm;
        break;
    }

    if (!adapter.ShutdownSession()) {
        std::cerr << "[genx-snes-ax] Warning: save flush or DAC lock release reported an issue.\n";
        return 1;
    }

    return 0;
}
```

### Top-Level `Generation-X-AX/CMakeLists.txt` Hook

```
option(GENX_BUILD_SNES "Build Generation-X-AX SNES adapter (genx-snes-ax)" ON)

if(GENX_BUILD_SNES)
    add_subdirectory(src/snes)
    add_executable(genx-snes-ax src/snes/genx_snes_main.cpp)
    target_link_libraries(genx-snes-ax PRIVATE ax_genx_snes)
endif()
```

---

## 2\. Wiring into `Piccolo-AX` (`batocera-ax-external`)

Add a `genx-snes-ax` package under `batocera-ax-external/package/genx-snes-ax/`, enable it in `batocera-ax-external/Config.in`, and install `ax-snes-launch.sh` alongside `ax_engine.ini`.

### `batocera-ax-external/package/genx-snes-ax/Config.in`

```
config BR2_PACKAGE_GENX_SNES_AX
	bool "genx-snes-ax"
	depends on BR2_PACKAGE_AX_SDK
	help
	  Deterministic SNES engine adapter (Generation-X-AX) for Piccolo-AX
	  with 2:3:1 topology, /dev/shm staging, /run/lock/ax-dac.lock audio
	  arbitration, and atomic save/SRAM flush.
```

### `batocera-ax-external/package/genx-snes-ax/genx-snes-ax.mk`

```
################################################################################
#
# genx-snes-ax
#
################################################################################

GENX_SNES_AX_VERSION = v1_36_2
GENX_SNES_AX_SITE_METHOD = local
GENX_SNES_AX_SITE = $(BR2_EXTERNAL_PICCOLO_AX_PATH)/../../Generation-X-AX
GENX_SNES_AX_DEPENDENCIES = ax-sdk
GENX_SNES_AX_CONF_OPTS = -DGENX_BUILD_SNES=ON

define GENX_SNES_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/build/genx-snes-ax $(TARGET_DIR)/usr/bin/genx-snes-ax
	$(INSTALL) -D -m 0755 $(@D)/scripts/ax-snes-launch.sh $(TARGET_DIR)/usr/bin/ax-snes-launch.sh
endef

$(eval $(cmake-package))
```

### `batocera-ax-external/Config.in` Entry

```
source "$BR2_EXTERNAL_PICCOLO_AX_PATH/package/genx-snes-ax/Config.in"
```

---

## 3\. Build & Verification Steps on `Piccolo-AX`

Configure \`Generation-X-AX\` with \`ax-sdk\` (\`v1\_36\_2\`) and compile \`genx-snes-ax\` using Ninja capped at four jobs. \*Verification:\* Build completes with zero errors and produces the \`genx-snes-ax\` binary. Install \`/usr/bin/genx-snes-ax\`, \`/usr/bin/ax-snes-launch.sh\`, and the \`\[snes\]\` \+ \`\[snes.presets.\*\]\` sections in \`/userdata/system/piccolo-ax/ax\_engine.ini\`. \*Verification:\* Running \`/usr/bin/ax-snes-launch.sh\` with no arguments prints usage and exits with code \`2\`. Launch a test SNES ROM via \`/usr/bin/ax-snes-launch.sh /userdata/roms/snes/test.sfc stock\_cycle\_exact\` and exit cleanly (\`SIGINT\`/\`SIGTERM\` or normal quit). \*Verification:\* Confirm \`/dev/shm/piccolo-ax/snes/roms/test.sfc\` was staged, \`/run/lock/ax-dac.lock\` was released on exit, and \`/userdata/saves/snes/test.srm\` matches the updated save state. 
