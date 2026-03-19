# Known Issues

## Scene rating and play-count sorting not working as expected

- Status: Open
- Area: Scene list sorting (server-side sort)
- Severity: Medium

### Symptom

- Selecting scene sort by rating or play count does not produce expected ordering.

### Notes

- The issue appears when using server-side sort through `FindFilterType.sort` and `FindFilterType.direction`.
- Other sort modes may still appear functional.

## Performer scene-count sorting not working as expected

- Status: Open
- Area: Performer list sorting (server-side sort)
- Severity: Medium

### Symptom

- Selecting performer sort by scene count does not produce expected ordering.

### Notes

- The issue appears when using server-side sort through `FindFilterType.sort` and `FindFilterType.direction`.
- Sorting behavior may differ from expected backend field mapping.


## First video playback startup is slow

- Status: Open
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

- The remaining delay appears to be backend-side warm-up/cold-start behavior for initial stream access.
- Client-side source choice is no longer the primary blocker for startup.
- The `+prewarm` strategy works to establish an early connection, but server-side transcoding/initialization still introduces a hard delay for certain stream sources.
- Contextual playback queue and Autoplay Next may mitigate perceived latency by buffering or initiating the next stream sooner, though pre-fetching the next stream in the background is not fully implemented.

### Next investigation ideas

- Measure startup time on the server side for first request versus warmed request.
- Compare startup latency between stream variants for the same scene under identical conditions.
- Implement background stream pre-fetching for the upcoming scene in the PlaybackQueue.
- Consider optional background prewarm earlier in app lifecycle (for users who opt in).
