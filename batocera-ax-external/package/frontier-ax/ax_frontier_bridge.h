#ifndef AX_FRONTIER_BRIDGE_H
#define AX_FRONTIER_BRIDGE_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum ax_frontier_domain_e {
    AX_FRONTIER_DOMAIN_AUDIO_TIMING = 0,
    AX_FRONTIER_DOMAIN_VULKAN_SUBMISSION = 1,
    AX_FRONTIER_DOMAIN_GUEST_JIT = 2,
    AX_FRONTIER_DOMAIN_HOUSEKEEPING = 3
} ax_frontier_domain_t;

typedef struct ax_frontier_arena_s {
    void* base;
    size_t size_bytes;
    uint8_t active_tier;
} ax_frontier_arena_t;

int ax_frontier_telemetry_init(void);
void ax_frontier_telemetry_shutdown(void);
void ax_frontier_record_audio_metrics(uint32_t duration_us, uint32_t ring_fill_frames);

int ax_frontier_pin_thread(ax_frontier_domain_t domain, int realtime_priority);

ax_frontier_arena_t ax_frontier_fastmem_alloc(size_t size_bytes, int prefer_1gb);
void ax_frontier_fastmem_free(ax_frontier_arena_t* arena);

#ifdef __cplusplus
}
#endif

#endif /* AX_FRONTIER_BRIDGE_H */
