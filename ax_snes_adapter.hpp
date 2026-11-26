#pragma once

#include "ui/ax_input_binder.hpp"

#include <atomic>
#include <array>
#include <cstdint>
#include <string>
#include <vector>

namespace ax::genx::snes {

enum class SnesPreset {
    StockCycleExact,
    CoprocessorBoost,
    LowLatencyInput,
};

enum class AudioFilterMode {
    Default,      // Unmodified cycle-accurate S-DSP output (default)
    ZsnesWarm,    // Filter 1: Nostalgic low-pass + subtle stereo width shaping
    CrtNearfield, // Filter 2: Mild high-frequency shelf tame for nearfield/DAC playback
};

struct SnesAudioFilterState {
    double b0{1.0};
    double b1{0.0};
    double b2{0.0};
    double a1{0.0};
    double a2{0.0};
    double z1_l{0.0};
    double z2_l{0.0};
    double z1_r{0.0};
    double z2_r{0.0};
    double crossfeed_mix{0.0};
};

struct SnesRuntimeConfig {
    bool enabled{true};
    std::string engine_backend{"bsnes"};
    SnesPreset preset{SnesPreset::StockCycleExact};
    AudioFilterMode audio_filter_mode{AudioFilterMode::Default};
    bool auto_detect_coprocessor{true};

    // 2:3:1 topology mapping (x86_64_coffeelake_maxwell_231)
    int audio_core{0};
    int audio_sched_fifo_priority{80};
    int video_core{1};
    std::vector<int> emu_cores{2, 3, 4};
    int housekeeping_core{5};

    // Audio & DAC lock (Core 0 ALSA S32_LE / DoP + HiBy FC3 / ES9281AC Pro)
    std::string alsa_device{"hw:CARD=FC3,DEV=0"};
    std::string alsa_format{"S32_LE"};
    uint32_t alsa_rate{48000};
    uint32_t alsa_period_frames{96};
    uint32_t alsa_buffer_periods{4};
    bool alsa_disable_resample{true};
    std::string dac_lock_path{"/run/lock/ax-dac.lock"};

    // SPC700 clock-locked rate guard
    bool rate_guard_enabled{true};
    int rate_guard_max_ppm{150};
    int rate_guard_ring_target_pct{50};
    int rate_guard_hysteresis_pct{5};

    // /dev/shm staging & atomic /userdata persistence
    bool shm_staging_enabled{true};
    std::string shm_rom_dir{"/dev/shm/piccolo-ax/snes/roms"};
    std::string shm_save_dir{"/dev/shm/piccolo-ax/snes/saves"};
    std::string persistent_save_dir{"/userdata/saves/snes"};
    std::string persistent_rom_dir{"/userdata/roms/snes"};
    std::string controls_config_path{"/userdata/system/piccolo-ax/snes_controls.cfg"};
    bool atomic_flush_on_exit{true};

    // Preset overrides
    uint32_t cpu_overclock_pct{100};
    uint32_t coprocessor_overclock_pct{100};
    int runahead_frames{0};
    bool thread_boost_coprocessor{false};
};

class AxSnesAdapter {
public:
    AxSnesAdapter() = default;
    ~AxSnesAdapter();

    AxSnesAdapter(const AxSnesAdapter&) = delete;
    AxSnesAdapter& operator=(const AxSnesAdapter&) = delete;

    // Loads ax_engine.ini via ax::LoadEngineConfig(), applies active preset and
    // AudioFilterMode, and resolves 2:3:1 topology/VRAM ceilings on Piccolo-AX.
    bool Initialize(const std::string& config_path, const std::string& rom_path);

    // Stages ROM & SRAM into /dev/shm on housekeeping core (Core 5) and
    // acquires exclusive /run/lock/ax-dac.lock + Core 0 SCHED_FIFO priority 80.
    bool StartSession();

    // Configures biquad/crossfeed coefficients for Default / ZsnesWarm / CrtNearfield
    // and processes interleaved stereo float samples on emulation/DSP cores (Cores 2-4).
    // Core 0 ALSA S32_LE ring writer remains lock-free and unallocated.
    void ConfigureAudioFilter(AudioFilterMode mode) noexcept;
    void ProcessAudioFilterStereo(float* interleaved_lr, std::size_t frame_count) noexcept;

    // Computes bounded PPM rate adjustment from current audio ring fill %
    // without allocating memory or blocking on Core 0.
    int ComputeRateGuardPpm(int current_ring_fill_pct) const noexcept;

    // Atomically persists controller bindings or config text via tmp + fsync + rename
    // + parent directory fsync on /userdata (invoked from Core 5 housekeeping).
    bool SaveSnesControlsAtomic(const ax::ui::retro::SnesControllerMap& map,
                                const std::string& target_path) const;
    bool WriteFileAtomic(const std::string& target_path, const std::string& content) const;

    // Flushes /dev/shm SRAM/saves atomically to /userdata/saves/snes,
    // triggers K01piccolo-sync hook if enabled, and releases DAC lock.
    bool ShutdownSession();

    const SnesRuntimeConfig& config() const noexcept { return cfg_; }
    AudioFilterMode audio_filter_mode() const noexcept { return cfg_.audio_filter_mode; }
    bool is_running() const noexcept { return running_.load(std::memory_order_acquire); }

private:
    bool AcquireDacLock();
    void ReleaseDacLock();
    bool StageRomAndSavesToShm();
    bool FlushSavesAtomicallyToStorage();
    void ApplyCoreAffinities();

    SnesRuntimeConfig cfg_{};
    SnesAudioFilterState filter_state_{};
    std::string rom_path_{};
    std::string staged_rom_path_{};
    std::string staged_sram_path_{};
    int dac_lock_fd_{-1};
    std::atomic<bool> running_{false};
};

} // namespace ax::genx::snes
