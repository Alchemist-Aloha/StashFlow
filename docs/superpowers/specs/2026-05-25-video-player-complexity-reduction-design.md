# Spec: Video Player Complexity Reduction

**Date:** 2026-05-25
**Topic:** Reduce complexity in video playback, queue advancement, and fullscreen handling without changing user-visible behavior.

## Problem

The video playback system works, but its responsibilities are concentrated in a few large modules:

- `lib/features/scenes/presentation/providers/video_player_provider.dart` owns media-kit player lifecycle, global state, preferences, subtitles, activity tracking, media-session callbacks, queue advancement, stream prewarming, fullscreen state, and navigation intents.
- `lib/features/scenes/presentation/widgets/scene_video_player.dart` and `lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart` render similar playback surfaces with duplicated transform, buffering, casting, subtitle, loading, and control wiring.
- Fullscreen truth is spread across `playerStateProvider.isFullScreen`, `PlayerViewMode`, route-path checks, `ShellPage` back handling, platform fullscreen APIs, and overlay-local animation state.
- Queue advancement currently resolves, navigates, updates queue index, and opens media from the player notifier, so failures can leave queue state, active scene, and background navigation out of sync.

This makes the system fragile when features cross boundaries: fullscreen autoplay, direct navigation, TikTok handoff, background playback, casting, subtitles, and resume tracking all interact with the same provider.

## Goals

- Keep current playback behavior intact while reducing coupling.
- Make the shared player ownership invariant explicit: only one scene owns the media-kit player at a time.
- Make inline and fullscreen rendering share one playback surface implementation.
- Make fullscreen enter/exit behavior deterministic across desktop, mobile, and web.
- Make queue next/previous transitions transactional: either the target scene is ready and committed, or existing playback state remains coherent.
- Improve testability by moving logic out of widgets and out of the monolithic player notifier.

## Non-Goals

- No media-kit replacement.
- No redesign of video controls.
- No change to queue semantics or existing queue IDs.
- No removal of TikTok playback handoff.
- No broad navigation rewrite beyond the playback/fullscreen boundaries.

## Recommended Approach

Use incremental extraction behind the existing `playerStateProvider` facade. This keeps call sites stable while the internals become smaller, testable units.

### Phase 1: Shared Player Surface

Create a reusable `PlayerSurface` widget used by both inline and fullscreen playback. It owns only rendering concerns:

- Transform matrix and pinch/rotate handlers.
- Debounced buffering indicator.
- Cast placeholder.
- `TransformableVideoSurface`.
- `NativeVideoControls` wiring.
- Subtitle alignment and sizing.
- Loading overlay.

`SceneVideoPlayer` remains responsible for deciding when a scene should start playback. `GlobalFullscreenOverlay` remains responsible for overlay visibility and platform fullscreen effects. Both delegate actual media surface rendering to `PlayerSurface`.

### Phase 2: Settings and Activity Extraction

Move preference-backed player settings into a `PlayerSettings` value and controller. Move play count, play duration, resume time, and periodic saving into a `PlaybackActivityTracker`.

The player notifier should ask these collaborators to load/apply settings and start/stop tracking, instead of storing their timers and preference keys directly.

### Phase 3: Session Lifecycle Extraction

Create a `PlaybackSessionController` that owns:

- `Player` creation.
- `VideoController` creation.
- `player.open(Media(effectiveStreamUrl, httpHeaders: headers, start: initialPosition))`.
- stream subscriptions.
- borrowed controller attach/detach semantics.
- disposal rules.

The public provider still exposes `GlobalPlayerState`, but the low-level session controller returns session snapshots/events instead of mutating unrelated state directly.

### Phase 4: Fullscreen State Machine

Replace scattered fullscreen booleans and route checks with explicit transitions:

- `inline`
- `enteringFullscreen`
- `fullscreen`
- `exitingFullscreen`
- `tiktok`

The fullscreen controller owns platform side effects:

- `SystemChrome.setEnabledSystemUIMode`.
- mobile orientation constraints.
- desktop `window_manager` fullscreen/maximize restore.
- web fullscreen entry/exit.

The overlay renders from this state; `ShellPage` handles back gestures by dispatching a fullscreen exit command.

### Phase 5: Queue Playback Coordinator

Move `playNext` and `playPrevious` into a coordinator that performs transitions atomically:

1. Read the active queue and current active scene.
2. Compute the target scene without mutating queue state.
3. Resolve the target stream.
4. Open or attach the target playback session.
5. Commit active scene, queue index, prewarm state, and navigation intent together.
6. If resolution/open fails, keep the previous queue index and active scene.

This coordinator should be the only module that combines queue state, stream resolution, navigation intent, and playback scene switching.

## Target Architecture

```text
SceneVideoPlayer
  - decides inline ownership and start conditions
  - delegates rendering to PlayerSurface

GlobalFullscreenOverlay
  - observes fullscreen mode
  - applies platform fullscreen side effects
  - delegates rendering to PlayerSurface

PlayerSurface
  - pure playback UI surface
  - receives scene, controller, player state, and callbacks

PlayerState facade
  - public provider used by existing widgets
  - delegates to focused services/controllers

PlaybackSessionController
  - media-kit player/controller lifecycle

PlaybackActivityTracker
  - play count, duration, resume saves

PlayerSettingsController
  - prefs-backed playback settings

QueuePlaybackCoordinator
  - next/previous transactions and navigation commands

FullscreenController
  - fullscreen mode transitions and platform side effects
```

## Invariants

- Fullscreen overlay always renders `playerState.activeScene`, never a local page scene.
- Entering fullscreen from a scene details page must first ensure `activeScene.id == pageScene.id`; if ownership cannot be acquired, fullscreen entry aborts.
- Inline scene players cannot reclaim the global player while fullscreen or TikTok mode owns it.
- Queue index changes only after the target scene is successfully selected for playback.
- Platform fullscreen side effects are paired: every enter path has a corresponding exit cleanup path.
- Player disposal must never dispose a borrowed TikTok controller unless ownership was explicitly transferred.

## Testing Strategy

- Add widget tests for `PlayerSurface` independent of fullscreen overlay and scene-details start rules.
- Keep existing `SceneVideoPlayer` and `GlobalFullscreenOverlay` tests as regression coverage after Phase 1.
- Add unit tests around extracted pure helpers: aspect ratio, resume-position eligibility, subtitle selection, queue target calculation, and fullscreen transition state.
- Add provider tests for queue transaction failure: failed stream resolution/open must not advance queue state.
- Keep targeted verification small per phase, then run broader scene/player tests before merging each phase.

## Success Criteria

- Inline and fullscreen player rendering use a single surface widget.
- `video_player_provider.dart`, `scene_video_player.dart`, and `global_fullscreen_overlay.dart` shrink through responsibility extraction without losing behavior.
- Fullscreen entry/exit and queue next/previous behavior are covered by targeted tests.
- Existing tests for scene video player, fullscreen mode, queue state, and play-end behavior continue to pass.
- Future fixes to buffering, casting, subtitles, controls, or transform behavior are made once in `PlayerSurface`.
