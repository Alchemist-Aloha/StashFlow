# Debugging Playbook

## Networking and server config

Symptoms:
- Host lookup or invalid URI errors

Checks:
1. Verify saved URL and key in Settings page.
2. Ensure URL has scheme (`https://...`).
3. Confirm INTERNET permission exists in Android main manifest for release behavior.

## GraphQL works but media fails

Symptoms:
- Lists load but thumbnails/video fail

Checks:
1. Confirm media URL resolution for relative paths.
2. Confirm `ApiKey` header is sent for media HTTP requests.
3. Compare failing URL against resolved absolute URL.

## Stream playback starts slowly

Symptoms:
- First playback in app session has high startup latency

Checks:
1. Read debug overlay (`mime`, `src`, `start`, `prewarm`).
2. Verify stream strategy setting (`prefer_scene_streams`).
3. Confirm one-time prewarm request executed by checking if `prewarm` shows `ok` or `fail` and latency.
4. Check if `src` includes `+header` (indicates extra roundtrip for MIME probing).
5. Compare first request vs second request latency for same scene.
6. Check app logs for provider lifecycle errors (`Cannot use the Ref of playerStateProvider after it has been disposed`).
7. Compare startup phase timings from logs:
	- `resolver query ... elapsed=...`
	- `resolver probe ... elapsed=...`
	- `provider initialize done ... elapsed=...`
	- `provider chewie ready ... chewieBuild=...`
	- `startup chewie-wait-done ... elapsed=...`
	- `provider first-frame ...`

Interpretation:
- Prewarm is now best-effort and non-blocking for player startup; it should not gate first frame display.
- If MIME is valid and first start is still slow after the non-blocking change, likely backend warm-up/cold-start.
- If `src` shows `autoplay-next`, it implies the stream was initiated via PlaybackQueue.
- If disposed-ref errors appear near startup logs, treat those as a separate lifecycle fault before concluding pure network/backend latency.
- If `provider initialize done` is high while resolver/probe/prewarm are low and `chewieBuild` is near zero, startup delay is not Chewie; investigate upstream/proxy/backend first-request behavior.

## Reverse proxy (Caddy) first-play delay

Symptoms:
- First play after idle/start takes seconds, while next plays start quickly.
- App logs show low resolver/probe/prewarm latency but high `provider initialize done` latency.

Checks:
1. Compare identical scene stream URL through Caddy vs direct upstream (first request and second request).
2. Check Caddy logs for upstream dial/connect/first-byte timing on stream endpoints.
3. Verify stream routes are not passing through response transforms/compression intended for text payloads.
4. Confirm reverse proxy transport reuse/keepalive and compare cold connection vs warmed connection behavior.
5. Confirm app uses normalized server URL and correct auth headers (ApiKey) to avoid retries/fallback noise.

Interpretation:
- If direct upstream is fast but proxied first request is slow, proxy config/path is the bottleneck.
- If both direct and proxied first request are slow, backend media pipeline warm-up is the bottleneck.
- Chewie timing near zero indicates UI layer is not responsible for first-play delay.

## Mini-player tap restarts playback

Symptoms:
- Tapping the mini-player to return to scene page restarts current playback.

Checks:
1. Confirm player provider remains alive across route transitions.
2. Verify startup log does not show repeated `startup begin` for same scene immediately after mini-player navigation.

Interpretation:
- Restart-on-tap is typically state disposal/rebuild during navigation, not a stream resolver issue.

## PiP includes full details page UI

Symptoms:
- Entering PiP captures scene details page chrome instead of video-only surface.

Checks:
1. Confirm PiP entry from controls forces fullscreen first.
2. Confirm auto-enter PiP on app pause is gated to fullscreen playback only.

Interpretation:
- Android PiP captures the current activity surface; entering from inline/details context can include non-video UI.

## Fullscreen seek gestures do not work

Symptoms:
- Drag seek or double-tap seek works inline but not in fullscreen.

Checks:
1. Verify seek interaction setting in Settings (`Drag` vs `Double-tap`).
2. Confirm custom controls are active (not default Chewie controls).
3. Ensure gestures are implemented inside `NativeVideoControls` (fullscreen route uses controls widget).

Interpretation:
- Page-level overlays do not apply in fullscreen Chewie route; gesture handling must live in the controls layer.

## Schema mismatch issues

Symptoms:
- GraphQL fields missing at runtime

Checks:
1. Remove unsupported fields from operation documents.
2. Regenerate code (`dart run build_runner build --delete-conflicting-outputs`).
## Sorting/filtering errors from backend

Symptoms:
- GraphQL error such as `invalid sort: ...`

Checks:
1. Confirm list page uses official sort key naming from server/web behavior.
2. Verify repository retry/fallback logic for known variants (for example `scenes_count` vs `scene_count`).
3. Confirm text search uses `FindFilterType.q` (not strict `EQUALS` criteria for keyword search).

## Troubleshooting Matrix

| Symptom | Probable Cause | Action |
| --- | --- | --- |
| White/blank screen on boot | Riverpod provider exception or routing failure | Check `flutter logs` for initialization errors. Verify `SettingsPage` redirect logic. |
| Endless loading spinner on list pages | Failed network request or zero results handling issue | Confirm server URL/API Key. Check if `AsyncValue.loading` is stuck due to unhandled exception in `fetchNextPage()`. |
| "Failed to load" ErrorStateView | GraphQL query rejection or network timeout | Read error details in UI. Run `flutter logs` for raw GraphQL exceptions. Verify `FindFilterType` compatibility. |
| Duplicate items in list | Pagination trigger firing multiple times | Verify `_isLoadingMore` lock in provider. Check scroll threshold in `ListPageScaffold`. |
| Player debug overlay shows `mime: unknown` | Stash backend not providing `mime_type` or stream is raw | Enable `+header` probing. Verify `StreamResolver.guessMimeType()` coverage. |
| "Add to Queue" does nothing | `PlaybackQueue` state not updating or Player not consuming it | Verify `PlaybackQueue` provider via devtools. Ensure `autoplayNext` is toggled on in player. |

## Random discovery behavior

Expected:
- Random actions on list pages are available via floating action button.
- Random fetch should respect active filters when invoked from filtered context.

If broken:
1. Verify corresponding provider has a `getRandom*` method using server `sort: 'random'`.
2. Verify page calls the provider method and handles `null` with snack bar.
3. Check route push target path and entity id.

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [#ui-guideline](#ui-guideline) for current UI standards.

# Known Issues

## Closed Recently

### Scene rating and play-count sorting mismatch

- Status: Closed (2026-03-20)
- Resolution: Implemented official `rating100` and `play_count` sort keys from server schema and added 5-star rating UI.

### Stream resolver failed when query returned data with cache re-read exception

- Status: Closed (2026-03-19)
- Resolution: Resolver now ignores cache re-read noise when stream data is present, continues with returned stream candidates, and logs sanitized exception summaries.

### Scene title fallback crash on malformed percent-encoded file/stream path

- Status: Closed (2026-03-19)
- Resolution: Title fallback path decoding now uses safe decode with graceful fallback, preventing Illegal percent encoding crashes.

### Scene switch could throw No active player with ID N

- Status: Closed (2026-03-19)
- Resolution: Scene switch flow detaches active player widget state before disposing old native player bindings.

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

- Status: Mitigated in app, likely upstream/proxy cold-path (2026-03-19), still re-validating
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
- New timing instrumentation confirms most first-play delay is inside native `VideoPlayerController.initialize()` for the first stream request, while resolver/probe/prewarm/Chewie phases are fast.
- Chewie creation is effectively zero-cost in current traces (`chewieBuild=0ms`), so Chewie is not the startup bottleneck.
- Remaining variability is now strongly associated with upstream/reverse-proxy/backend first-request warm-up behavior (for example Caddy upstream cold path), not app UI/control logic.
- Additional instability can still come from provider lifecycle timing under rapid route/app-state transitions (disposed-ref errors observed in logs), which can mask startup timing diagnostics.
- Contextual playback queue and Autoplay Next may still help perceived latency, though full next-scene prefetch is not implemented.

### Next investigation ideas

- Re-measure first-play startup with Caddy bypassed versus through proxy for identical stream URL.
- Capture first-byte and response-start timing at proxy and upstream to isolate cold-path cost.
- For Caddy, verify stream-route reverse proxy behavior (streaming flush/compression/transport) and compare first request versus warmed request.
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
See [#ui-guideline](#ui-guideline) for current UI standards.