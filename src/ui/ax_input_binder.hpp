#pragma once

#include <array>
#include <cstddef>
#include <cstdint>
#include <string_view>

namespace ax::ui::retro {

enum class SnesButton : std::size_t {
    Up = 0, Down, Left, Right, Start, Select, A, B, X, Y, L, R, Count
};

inline constexpr std::array<std::string_view, static_cast<std::size_t>(SnesButton::Count)> kBindPrompts = {{
    "PRESS UP",
    "PRESS DOWN",
    "PRESS LEFT",
    "PRESS RIGHT",
    "PRESS START",
    "PRESS SELECT",
    "PRESS A (RIGHT BUTTON)",
    "PRESS B (DOWN BUTTON)",
    "PRESS X (TOP BUTTON)",
    "PRESS Y (LEFT BUTTON)",
    "PRESS L SHOULDER",
    "PRESS R SHOULDER",
}};

struct SnesControllerMap {
    std::array<std::uint32_t, static_cast<std::size_t>(SnesButton::Count)> codes{};
};

class SequentialInputBinder {
public:
    void Begin() noexcept {
        step_ = 0;
        active_ = true;
    }

    void Cancel() noexcept { active_ = false; }

    [[nodiscard]] bool is_active() const noexcept { return active_; }

    [[nodiscard]] std::string_view current_prompt() const noexcept {
        return active_ && step_ < kBindPrompts.size() ? kBindPrompts[step_] : std::string_view{};
    }

    bool RecordInputCode(std::uint32_t input_code) noexcept {
        if (!active_ || step_ >= kBindPrompts.size()) {
            return false;
        }
        pending_.codes[step_] = input_code;
        ++step_;
        if (step_ >= kBindPrompts.size()) {
            active_ = false;
            return true;
        }
        return false;
    }

    [[nodiscard]] const SnesControllerMap& result() const noexcept { return pending_; }

private:
    std::size_t step_ = 0;
    bool active_ = false;
    SnesControllerMap pending_{};
};

} // namespace ax::ui::retro
