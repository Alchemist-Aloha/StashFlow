# Known Issues

## Closed Recently

### Mini-player "Now Playing" tap restarted current playback

- Status: Closed (2026-03-19)
- Resolution: Kept player provider alive across route transitions so navigation to scene details no longer reinitializes the active media session.

### PiP showed scene details page instead of video-only content

- Status: Closed (2026-03-19)
- Resolution: PiP entry now prefers fullscreen player context and auto-enter on app pause only triggers from fullscreen playback state.

### Scene rating and play-count sorting mismatch

- Status: Closed (2026-03-19)
- Resolution: Switched to official sort keys with fallback handling.

### Performer/studio/tag scene-count sort mismatch

- Status: Closed (2026-03-19)
- Resolution: Aligned to `scenes_count` with compatibility fallback and local fallback sort.


## First video playback startup is slow

- Status: Mitigated (2026-03-19), still re-validating
- Area: Scene playback / streaming startup
- Severity: Medium

### Symptom

- The first scene playback in an app session may take around 8 seconds to start.
- Typical debug overlay values observed:
  - `mime: video/mp4`
  - `src: paths.stream+header`
  - `start: ~8350ms`

### What already works

- MIME detection now resolves correctly, including HTTP header probing fallback.
- Playback source selection works with setting-based control:
  - Try `sceneStreams` first, or
  - Directly use `paths.stream`.
- Auth headers are passed for stream requests.
- One-time prewarm call (ranged GET with headers) to `paths.stream` is implemented.

### Current understanding

- App-side root cause was identified: playback startup path awaited prewarm before calling player start, which could block for up to the prewarm timeout budget and matched the ~8 second delay pattern.
- Mitigation was applied: prewarm now runs in background and no longer blocks `playScene`.
- Remaining variability can still come from backend cold start/transcoding on first request.
- Additional instability can still come from provider lifecycle timing under rapid route/app-state transitions (disposed-ref errors observed in logs), which can mask startup timing diagnostics.
- Contextual playback queue and Autoplay Next may still help perceived latency, though full next-scene prefetch is not implemented.

### Next investigation ideas

- Re-measure first-play startup after the non-blocking prewarm change.
- Re-measure with new lifecycle guards and provider keep-alive enabled to rule out disposal races.
- Compare startup latency between stream variants for the same scene under identical conditions.
- Measure server-side first-request warm-up time to separate backend latency from client latency.
- Implement optional next-scene prefetch in PlaybackQueue.

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
