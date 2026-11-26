#include "snes/ax_snes_adapter.hpp"
#include "ui/ax_input_binder.hpp"
#include "ui/ax_retro_chrome.hpp"
#include "ui/ax_retro_font.hpp"

#include <array>
#include <cassert>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>

namespace fs = std::filesystem;

int main() {
    // 1. Verify 5x5 bitmap font mapping & custom override
    ax::ui::retro::RetroBitmapFont font;
    assert(font.MapAsciiToGlyph('A') == 0x0B);
    assert(font.MapAsciiToGlyph('0') == 0x01);
    assert(font.MapAsciiToGlyph(':') == 0x2E);

    const fs::path tmp_dir = fs::temp_directory_path() / "piccolo_ax_ci_snes";
    std::error_code ec;
    fs::remove_all(tmp_dir, ec);
    fs::create_directories(tmp_dir, ec);

    const fs::path font_file = tmp_dir / "zfont.txt";
    {
        std::ofstream out(font_file);
        out << "; custom glyph 0\n"
            << "11111000\n"
            << "10000000\n"
            << "11110000\n"
            << "10000000\n"
            << "10000000\n"
            << "EOF\n";
    }
    assert(font.LoadOverrideFile(font_file.string()));
    assert(font.Glyph(0)[0] == 0xF8);

    // 2. Verify 3D chrome, shadowed text, and scanlines on preallocated buffer
    constexpr int kW = 160;
    constexpr int kH = 32;
    std::array<std::uint32_t, static_cast<std::size_t>(kW * kH)> pixels{};
    const ax::ui::retro::FramebufferView fb{pixels.data(), kW, kH, kW};
    ax::ui::retro::DrawBox3D(fb, 2, 2, kW - 3, kH - 3, {}, true);
    ax::ui::retro::DrawTextShadowed(fb, font, 8, 14, "FLT:ZSNES_WARM", 0xFFF4F6FF, 0xFF080A14, 1);
    ax::ui::retro::ApplyScanlines(fb, 25);
    assert(pixels[static_cast<std::size_t>(1 * kW + 0)] == 0x00000000);

    // 3. Verify 12-button sequential binder + atomic persistence
    ax::ui::retro::SequentialInputBinder binder;
    binder.Begin();
    assert(binder.is_active());
    assert(binder.current_prompt() == "PRESS UP");

    bool completed = false;
    for (std::size_t i = 0; i < static_cast<std::size_t>(ax::ui::retro::SnesButton::Count); ++i) {
        completed = binder.RecordInputCode(static_cast<std::uint32_t>(100 + i));
    }
    assert(completed);
    assert(!binder.is_active());

    const fs::path dummy_rom = tmp_dir / "test_cart.sfc";
    {
        std::ofstream rom_out(dummy_rom, std::ios::binary);
        rom_out << "SNES_CI_TEST_ROM";
    }

    const fs::path cfg_file = tmp_dir / "ax_engine.ini";
    {
        std::ofstream cfg_out(cfg_file);
        cfg_out << "[snes]\n"
                << "enabled = true\n"
                << "engine_backend = \"bsnes\"\n"
                << "profile_preset = \"stock_cycle_exact\"\n"
                << "audio_filter_mode = \"default\"\n"
                << "shm_staging_enabled = false\n"
                << "dac_lock_path = \"" << (tmp_dir / "ax-dac.lock").string() << "\"\n"
                << "persistent_save_dir = \"" << (tmp_dir / "saves").string() << "\"\n";
    }

    const fs::path controls_out = tmp_dir / "snes_controls.cfg";
    ax::genx::snes::AxSnesAdapter adapter;
    assert(adapter.Initialize(cfg_file.string(), dummy_rom.string()));
    assert(adapter.SaveSnesControlsAtomic(binder.result(), controls_out.string()));
    assert(fs::exists(controls_out));

    // 4. Verify all 3 audio filters (default, zsnes_warm, crt_nearfield) & rate guard
    std::array<float, 64> stereo{};
    for (std::size_t i = 0; i < stereo.size(); i += 2) {
        stereo[i] = 0.5F;
        stereo[i + 1] = -0.25F;
    }

    adapter.ConfigureAudioFilter(ax::genx::snes::AudioFilterMode::Default);
    assert(adapter.audio_filter_mode() == ax::genx::snes::AudioFilterMode::Default);
    adapter.ProcessAudioFilterStereo(stereo.data(), 32);

    adapter.ConfigureAudioFilter(ax::genx::snes::AudioFilterMode::ZsnesWarm);
    assert(adapter.audio_filter_mode() == ax::genx::snes::AudioFilterMode::ZsnesWarm);
    adapter.ProcessAudioFilterStereo(stereo.data(), 32);

    adapter.ConfigureAudioFilter(ax::genx::snes::AudioFilterMode::CrtNearfield);
    assert(adapter.audio_filter_mode() == ax::genx::snes::AudioFilterMode::CrtNearfield);
    adapter.ProcessAudioFilterStereo(stereo.data(), 32);

    assert(adapter.ComputeRateGuardPpm(50) == 0);
    assert(adapter.ComputeRateGuardPpm(65) == 150);

    fs::remove_all(tmp_dir, ec);
    std::cout << "[PASS] snes_retro_smoke_test\n";
    return 0;
}
