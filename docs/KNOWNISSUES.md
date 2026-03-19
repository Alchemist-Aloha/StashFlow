# Known Issues

## Closed Recently

### Scene rating and play-count sorting mismatch

- Status: Closed (2026-03-19)
- Resolution: Switched to official sort keys with fallback handling.

### Performer/studio/tag scene-count sort mismatch

- Status: Closed (2026-03-19)
- Resolution: Aligned to `scenes_count` with compatibility fallback and local fallback sort.


## First video playback startup is slow

- Status: Resolved (2026-03-19)
- Area: Scene playback / streaming startup
- Severity: Medium

### Symptom

- The first scene playback in an app session could take around 8 seconds to start.
- Typical debug overlay values observed:
  - `mime: video/mp4`
  - `src: paths.stream+header`
  - `start: ~8350ms`

### Root Cause Analysis

After investigating the official Stash webapp (https://github.com/stashapp/stash), several architectural differences were identified:

1. **Double Connection Overhead**: The Flutter app was making two separate HTTP requests:
   - A prewarm request with `Range: bytes=0-0` header
   - Then full video initialization with VideoPlayerController
   - Each request required TCP handshake, TLS negotiation, and HTTP headers

2. **HLS Preference Over Direct Stream**: The app prioritized HLS (score: 300) over direct MP4 streaming (score: 220)
   - HLS requires downloading .m3u8 manifest first, then parsing segments, then starting first segment download
   - This added 2-3 RTT (Round Trip Times) compared to direct streaming

3. **Browser Optimizations Not Available**: The webapp uses Video.js with `preload: "none"` and leverages browser's native optimizations (connection reuse, DNS prefetching, socket pooling), which Flutter's video_player doesn't have

### Resolution

The following changes were implemented:

1. **Removed prewarm strategy entirely** (scene_video_player.dart)
   - Eliminated the wasteful Range: bytes=0-0 request
   - Let VideoPlayerController handle connection directly
   - Removed `_prewarmPathsStreamOnce()` and `_prewarmStreamRequest()` methods
   - Removed `_PrewarmResult` class and prewarm-related state tracking

2. **Prioritized direct stream over HLS/DASH** (stream_resolver.dart)
   - Changed scoring: Direct MP4 stream now scores 300 (highest priority)
   - Regular MP4: 250, HLS: 200, DASH: 150
   - This avoids manifest parsing overhead for most common playback scenarios

3. **Simplified state management** (video_player_provider.dart)
   - Removed prewarmAttempted, prewarmSucceeded, and prewarmLatencyMs from GlobalPlayerState
   - Simplified playScene() method signature
   - Updated debug overlay to remove prewarm information

### Expected Impact

These changes should significantly reduce cold-start video playback latency by:
- Eliminating one full HTTP request cycle (~2-3 seconds)
- Avoiding HLS manifest parsing overhead (~1-2 seconds)
- Reducing total latency from ~8 seconds to approximately 2-3 seconds

### Files Modified

- `/lib/features/scenes/data/repositories/stream_resolver.dart` - Stream prioritization scoring
- `/lib/features/scenes/presentation/widgets/scene_video_player.dart` - Removed prewarm logic
- `/lib/features/scenes/presentation/providers/video_player_provider.dart` - Removed prewarm state


## Optional Consistency Follow-ups

### Sort default direction consistency per field

- Status: Open
- Area: List-page UX consistency
- Severity: Low

### Lightweight list-page widget tests for sort/filter panel flows

- Status: Open
- Area: UI regression safety
- Severity: Low

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [UIGUIDELINE.md](UIGUIDELINE.md) for current UI standards.
