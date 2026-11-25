#include "snes/ax_snes_adapter.hpp"
#include "ui/ax_input_binder.hpp"
#include "ui/ax_retro_chrome.hpp"
#include "ui/ax_retro_font.hpp"

#include <csignal>
#include <iostream>
#include <string>

namespace {
volatile std::sig_atomic_t g_stop_flag = 0;

void HandleSignal(int signum) {
    (void)signum;
    g_stop_flag = 1;
}
} // namespace

int main(int argc, char** argv) {
    std::string config_path = "/userdata/system/piccolo-ax/ax_engine.ini";
    std::string rom_path;
    bool retro_chrome = true;
    int scanline_pct = 25;

    for (int i = 1; i < argc; ++i) {
        const std::string arg = argv[i];
        if (arg == "--config" && i + 1 < argc) {
            config_path = argv[++i];
        } else if (arg == "--rom" && i + 1 < argc) {
            rom_path = argv[++i];
        } else if (arg == "--no-retro-chrome") {
            retro_chrome = false;
        } else if (arg == "--scanlines" && i + 1 < argc) {
            scanline_pct = std::stoi(argv[++i]);
        }
    }

    if (rom_path.empty()) {
        std::cerr << "[genx-snes-ax] Missing required --rom <path>\n";
        return 2;
    }

    std::signal(SIGINT, HandleSignal);
    std::signal(SIGTERM, HandleSignal);
    std::signal(SIGUSR1, HandleSignal);

    ax::ui::retro::RetroBitmapFont font;
    (void)font.LoadOverrideFile("/userdata/system/piccolo-ax/zfont.txt");

    ax::genx::snes::AxSnesAdapter adapter;
    if (!adapter.Initialize(config_path, rom_path) || !adapter.StartSession()) {
        std::cerr << "[genx-snes-ax] Failed to initialize/start Piccolo-AX SNES session\n";
        return 1;
    }

    // Example Core 1 / HUD staging buffer usage (kept off Core 0 audio & Cores 2-4 emu)
    if (retro_chrome && scanline_pct >= 0) {
        std::cout << "[genx-snes-ax] Piccolo-AX retro UI active (scanlines="
                  << scanline_pct << "%)\n";
    }

    while (!g_stop_flag) {
        const int ppm = adapter.ComputeRateGuardPpm(50);
        (void)ppm;
        break;
    }

    if (!adapter.ShutdownSession()) {
        std::cerr << "[genx-snes-ax] Save flush or DAC lock release warning\n";
        return 1;
    }
    return 0;
}
