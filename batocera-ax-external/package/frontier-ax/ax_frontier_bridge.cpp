#include "ax_frontier_bridge.h"

#include "ax/memory.hpp"
#include "ax/telemetry.hpp"
#include "ax/topology.hpp"

namespace {

ax::topology::Domain ToAxDomain(ax_frontier_domain_t domain) noexcept {
    switch (domain) {
        case AX_FRONTIER_DOMAIN_AUDIO_TIMING:
            return ax::topology::Domain::AudioTiming;
        case AX_FRONTIER_DOMAIN_VULKAN_SUBMISSION:
            return ax::topology::Domain::VulkanSubmission;
        case AX_FRONTIER_DOMAIN_GUEST_JIT:
            return ax::topology::Domain::GuestJit;
        case AX_FRONTIER_DOMAIN_HOUSEKEEPING:
        default:
            return ax::topology::Domain::Housekeeping;
    }
}

ax::memory::PageTier ToAxPageTier(uint8_t tier) noexcept {
    switch (tier) {
        case 1:
            return ax::memory::PageTier::Huge2M;
        case 2:
            return ax::memory::PageTier::Huge1G;
        case 0:
        default:
            return ax::memory::PageTier::Standard4K;
    }
}

} // namespace

extern "C" {

int ax_frontier_telemetry_init(void) {
    return ax::InitTelemetryShm() ? 1 : 0;
}

void ax_frontier_telemetry_shutdown(void) {
    ax::ShutdownTelemetryShm();
}

void ax_frontier_record_audio_metrics(uint32_t duration_us, uint32_t ring_fill_frames) {
    ax::RecordAudioCallbackMetrics(duration_us, ring_fill_frames);
}

int ax_frontier_pin_thread(ax_frontier_domain_t domain, int realtime_priority) {
    return ax::topology::PinCurrentThread(ToAxDomain(domain), realtime_priority) ? 1 : 0;
}

ax_frontier_arena_t ax_frontier_fastmem_alloc(size_t size_bytes, int prefer_1gb) {
    ax::memory::ArenaHandle handle = ax::memory::AllocateFastmemArena(size_bytes, prefer_1gb != 0);
    ax_frontier_arena_t out{};
    out.base = handle.base;
    out.size_bytes = handle.size_bytes;
    out.active_tier = static_cast<uint8_t>(handle.active_tier);
    return out;
}

void ax_frontier_fastmem_free(ax_frontier_arena_t* arena) {
    if (arena == nullptr || arena->base == nullptr) {
        return;
    }
    ax::memory::ArenaHandle handle{};
    handle.base = arena->base;
    handle.size_bytes = arena->size_bytes;
    handle.active_tier = ToAxPageTier(arena->active_tier);
    ax::memory::FreeFastmemArena(handle);
    arena->base = nullptr;
    arena->size_bytes = 0;
    arena->active_tier = static_cast<uint8_t>(ax::memory::PageTier::Standard4K);
}

} // extern "C"
