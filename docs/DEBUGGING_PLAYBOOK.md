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

Interpretation:
- If MIME is valid and only first start is slow, likely backend warm-up/cold-start.
- If `src` shows `autoplay-next`, it implies the stream was initiated via PlaybackQueue.

## Schema mismatch issues

Symptoms:
- GraphQL fields missing at runtime

Checks:
1. Remove unsupported fields from operation documents.
2. Regenerate code (`dart run build_runner build --delete-conflicting-outputs`).
3. Re-run analyze/tests.

## Troubleshooting Matrix

| Symptom | Probable Cause | Action |
| --- | --- | --- |
| White/blank screen on boot | Riverpod provider exception or routing failure | Check `flutter logs` for initialization errors. Verify `SettingsPage` redirect logic. |
| Endless loading spinner on list pages | Failed network request or zero results handling issue | Confirm server URL/API Key. Check if `AsyncValue.loading` is stuck due to unhandled exception in `fetchNextPage()`. |
| "Failed to load" ErrorStateView | GraphQL query rejection or network timeout | Read error details in UI. Run `flutter logs` for raw GraphQL exceptions. Verify `FindFilterType` compatibility. |
| Duplicate items in list | Pagination trigger firing multiple times | Verify `_isLoadingMore` lock in provider. Check scroll threshold in `ListPageScaffold`. |
| Player debug overlay shows `mime: unknown` | Stash backend not providing `mime_type` or stream is raw | Enable `+header` probing. Verify `StreamResolver.guessMimeType()` coverage. |
| "Add to Queue" does nothing | `PlaybackQueue` state not updating or Player not consuming it | Verify `PlaybackQueue` provider via devtools. Ensure `autoplayNext` is toggled on in player. |
