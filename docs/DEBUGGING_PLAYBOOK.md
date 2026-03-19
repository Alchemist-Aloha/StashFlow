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

Interpretation:
- Prewarm is now best-effort and non-blocking for player startup; it should not gate first frame display.
- If MIME is valid and first start is still slow after the non-blocking change, likely backend warm-up/cold-start.
- If `src` shows `autoplay-next`, it implies the stream was initiated via PlaybackQueue.
- If disposed-ref errors appear near startup logs, treat those as a separate lifecycle fault before concluding pure network/backend latency.

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
3. Ensure gestures are implemented inside `ScrubChewieControls` (fullscreen route uses controls widget).

Interpretation:
- Page-level overlays do not apply in fullscreen Chewie route; gesture handling must live in the controls layer.

## Schema mismatch issues

Symptoms:
- GraphQL fields missing at runtime

Checks:
1. Remove unsupported fields from operation documents.
2. Regenerate code (`dart run build_runner build --delete-conflicting-outputs`).
3. Re-run analyze/tests.

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
See [UIGUIDELINE.md](UIGUIDELINE.md) for current UI standards.
