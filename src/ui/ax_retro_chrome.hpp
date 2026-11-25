#pragma once

#include "ax_retro_font.hpp"

#include <algorithm>
#include <cstdint>
#include <string_view>

namespace ax::ui::retro {

struct RetroThemePalette {
    std::uint32_t panel_fill   = 0xFF1E2448;
    std::uint32_t border_light = 0xFF6A78B8;
    std::uint32_t border_dark  = 0xFF0C1024;
    std::uint32_t title_bar    = 0xFF2E3A70;
    std::uint32_t text_fg      = 0xFFF4F6FF;
    std::uint32_t text_shadow  = 0xFF080A14;
    std::uint32_t accent_amber = 0xFF38A8F8;
};

struct FramebufferView {
    std::uint32_t* pixels = nullptr;
    int width = 0;
    int height = 0;
    int stride_pixels = 0;

    void PutPixel(int x, int y, std::uint32_t rgba) const noexcept {
        if (!pixels || x < 0 || y < 0 || x >= width || y >= height) {
            return;
        }
        pixels[y * stride_pixels + x] = rgba;
    }
};

inline void DrawBox3D(const FramebufferView& fb,
                      int x1, int y1, int x2, int y2,
                      const RetroThemePalette& pal = {},
                      bool with_titlebar = true) noexcept {
    if (x2 <= x1 || y2 <= y1) return;
    const int cx1 = std::max(0, x1);
    const int cy1 = std::max(0, y1);
    const int cx2 = std::min(fb.width - 1, x2);
    const int cy2 = std::min(fb.height - 1, y2);

    for (int y = cy1; y <= cy2; ++y) {
        for (int x = cx1; x <= cx2; ++x) {
            fb.PutPixel(x, y, pal.panel_fill);
        }
    }
    if (with_titlebar && (y1 + 10) < y2) {
        for (int y = std::max(0, y1 + 1); y <= std::min(fb.height - 1, y1 + 9); ++y) {
            for (int x = std::max(0, x1 + 1); x <= std::min(fb.width - 1, x2 - 1); ++x) {
                fb.PutPixel(x, y, pal.title_bar);
            }
        }
    }
    for (int x = x1; x <= x2; ++x) {
        fb.PutPixel(x, y1, pal.border_light);
        fb.PutPixel(x, y2, pal.border_dark);
    }
    for (int y = y1; y <= y2; ++y) {
        fb.PutPixel(x1, y, pal.border_light);
        fb.PutPixel(x2, y, pal.border_dark);
    }
}

inline void DrawTextShadowed(const FramebufferView& fb,
                             const RetroBitmapFont& font,
                             int x, int y,
                             std::string_view text,
                             std::uint32_t fg = 0xFFF4F6FF,
                             std::uint32_t shadow = 0xFF080A14,
                             int scale = 1) noexcept {
    const int s = std::max(1, scale);
    int cursor_x = x;
    for (char ch : text) {
        const auto& glyph = font.Glyph(font.MapAsciiToGlyph(ch));
        for (int row = 0; row < kGlyphHeight; ++row) {
            const std::uint8_t bits = glyph[static_cast<std::size_t>(row)];
            for (int col = 0; col < kGlyphWidth; ++col) {
                if ((bits & (0x80U >> col)) != 0) {
                    for (int dy = 0; dy < s; ++dy) {
                        for (int dx = 0; dx < s; ++dx) {
                            const int px = cursor_x + col * s + dx;
                            const int py = y + row * s + dy;
                            fb.PutPixel(px + s, py + s, shadow);
                            fb.PutPixel(px, py, fg);
                        }
                    }
                }
            }
        }
        cursor_x += (kGlyphWidth + 1) * s;
    }
}

inline void ApplyScanlines(const FramebufferView& fb, int intensity_pct) noexcept {
    const int clamped = std::clamp(intensity_pct, 0, 100);
    if (!fb.pixels || clamped == 0) return;
    const std::uint32_t keep = static_cast<std::uint32_t>(100 - clamped);
    for (int y = 1; y < fb.height; y += 2) {
        std::uint32_t* row = fb.pixels + y * fb.stride_pixels;
        for (int x = 0; x < fb.width; ++x) {
            const std::uint32_t c = row[x];
            const std::uint32_t r = ((c & 0xFFU) * keep) / 100U;
            const std::uint32_t g = (((c >> 8U) & 0xFFU) * keep) / 100U;
            const std::uint32_t b = (((c >> 16U) & 0xFFU) * keep) / 100U;
            row[x] = (c & 0xFF000000U) | (b << 16U) | (g << 8U) | r;
        }
    }
}

} // namespace ax::ui::retro
