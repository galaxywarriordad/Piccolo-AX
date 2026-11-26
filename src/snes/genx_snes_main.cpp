#include "snes/ax_snes_adapter.hpp"
#include "ui/ax_input_binder.hpp"
#include "ui/ax_retro_chrome.hpp"
#include "ui/ax_retro_font.hpp"

#include <algorithm>
#include <array>
#include <csignal>
#include <iostream>
#include <string>

namespace {

volatile std::sig_atomic_t g_stop_flag = 0;

void HandleSignal(int signum) {
    (void)signum;
    g_stop_flag = 1;
}

int ParseScanlinesArg(const std::string& raw) {
    try {
        const int parsed = std::stoi(raw);
        return std::clamp(parsed, 0, 100);
    } catch (...) {
        return 25;
    }
}

bool ParseFilterArg(const std::string& raw, ax::genx::snes::AudioFilterMode& out_mode) {
    using ax::genx::snes::AudioFilterMode;
    if (raw == "default") {
        out_mode = AudioFilterMode::Default;
        return true;
    }
    if (raw == "zsnes_warm") {
        out_mode = AudioFilterMode::ZsnesWarm;
        return true;
    }
    if (raw == "crt_nearfield") {
        out_mode = AudioFilterMode::CrtNearfield;
        return true;
    }
    return false;
}

const char* FilterLabel(ax::genx::snes::AudioFilterMode mode) noexcept {
    using ax::genx::snes::AudioFilterMode;
    switch (mode) {
        case AudioFilterMode::ZsnesWarm: return "ZSNES_WARM";
        case AudioFilterMode::CrtNearfield: return "CRT_NEARFIELD";
        case AudioFilterMode::Default:
        default: return "DEFAULT";
    }
}

const char* PresetLabel(ax::genx::snes::SnesPreset preset) noexcept {
    using ax::genx::snes::SnesPreset;
    switch (preset) {
        case SnesPreset::CoprocessorBoost: return "COPROC_BOOST";
        case SnesPreset::LowLatencyInput: return "LOW_LATENCY";
        case SnesPreset::StockCycleExact:
        default: return "STOCK_EXACT";
    }
}

} // namespace

int main(int argc, char** argv) {
    std::string config_path = "/userdata/system/piccolo-ax/ax_engine.ini";
    std::string rom_path;
    bool retro_chrome = true;
    int scanline_pct = 25;
    bool has_filter_override = false;
    ax::genx::snes::AudioFilterMode filter_override = ax::genx::snes::AudioFilterMode::Default;

    for (int i = 1; i < argc; ++i) {
        const std::string arg = argv[i];
        if (arg == "--config" && i + 1 < argc) {
            config_path = argv[++i];
        } else if (arg == "--rom" && i + 1 < argc) {
            rom_path = argv[++i];
        } else if (arg == "--no-retro-chrome") {
            retro_chrome = false;
        } else if (arg == "--scanlines" && i + 1 < argc) {
            scanline_pct = ParseScanlinesArg(argv[++i]);
        } else if (arg == "--filter" && i + 1 < argc) {
            if (ParseFilterArg(argv[++i], filter_override)) {
                has_filter_override = true;
            } else {
                std::cerr << "[genx-snes-ax] Unknown --filter value; using default\n";
            }
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
    if (!adapter.Initialize(config_path, rom_path)) {
        std::cerr << "[genx-snes-ax] Failed to initialize Piccolo-AX SNES session\n";
        return 1;
    }

    if (has_filter_override) {
        adapter.ConfigureAudioFilter(filter_override);
    }

    if (!adapter.StartSession()) {
        std::cerr << "[genx-snes-ax] Failed to start Piccolo-AX SNES session\n";
        return 1;
    }

    // Example preallocated Core 1 HUD strip buffer (0 heap allocations in loop)
    constexpr int kHudW = 320;
    constexpr int kHudH = 24;
    std::array<std::uint32_t, static_cast<std::size_t>(kHudW * kHudH)> hud_buf{};
    const ax::ui::retro::FramebufferView hud_fb{
        hud_buf.data(), kHudW, kHudH, kHudW
    };

    if (retro_chrome) {
        ax::ui::retro::DrawBox3D(hud_fb, 0, 0, kHudW - 1, kHudH - 1, {}, false);
        const std::string status = std::string(PresetLabel(adapter.config().preset)) +
                                   " | FLT:" + FilterLabel(adapter.audio_filter_mode());
        ax::ui::retro::DrawTextShadowed(hud_fb, font, 6, 6, status, 0xFFF4F6FF, 0xFF080A14, 1);
        ax::ui::retro::ApplyScanlines(hud_fb, scanline_pct);
        std::cout << "[genx-snes-ax] Piccolo-AX UI active (" << status
                  << ", scanlines=" << scanline_pct << "%)\n";
    }

    // Example preallocated stereo frame buffer for non-Core-0 DSP stage (Cores 2-4)
    std::array<float, 96 * 2> stereo_frames{};

    while (!g_stop_flag) {
        adapter.ProcessAudioFilterStereo(stereo_frames.data(), 96);
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
