# Video Player Complexity Reduction Roadmap

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce complexity in StashFlow video playback, queue advancement, and fullscreen handling while preserving current behavior.

**Architecture:** Keep `playerStateProvider` as the stable public facade while extracting focused widgets and controllers behind it. Start with the lowest-risk UI duplication, then move preference/activity/session/fullscreen/queue logic into testable units.

**Tech Stack:** Flutter, Riverpod code generation, media_kit, media_kit_video, go_router, window_manager, flutter_test.

---

## File Structure

- Create: `lib/features/scenes/presentation/widgets/player_surface.dart`
  - Shared inline/fullscreen playback rendering surface.
- Modify: `lib/features/scenes/presentation/widgets/scene_video_player.dart`
  - Keep ownership/start rules; delegate active playback rendering to `PlayerSurface`.
- Modify: `lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart`
  - Keep overlay animation/platform fullscreen; delegate active playback rendering to `PlayerSurface`.
- Create later: `lib/features/scenes/presentation/providers/player_settings_controller.dart`
  - Preference-backed playback settings.
- Create later: `lib/features/scenes/presentation/providers/playback_activity_tracker.dart`
  - Play count, duration, resume-time tracking.
- Create later: `lib/features/scenes/presentation/providers/playback_session_controller.dart`
  - media-kit session lifecycle.
- Create later: `lib/features/scenes/presentation/providers/fullscreen_controller.dart`
  - Fullscreen mode transitions and platform side effects.
- Create later: `lib/features/scenes/presentation/providers/queue_playback_coordinator.dart`
  - Transactional next/previous playback.

## Phase 1: Extract `PlayerSurface`

Use the detailed plan in `docs/superpowers/plans/2026-05-25-player-surface-extraction.md`.

Expected result:

- `SceneVideoPlayer` and `GlobalFullscreenOverlay` both use `PlayerSurface`.
- Rendering behavior remains unchanged.
- Duplicate transform, buffering, casting, subtitle alignment, and control wiring is removed from the two parent widgets.

Verification:

```bash
rtk flutter test test/features/scenes/presentation/widgets/scene_video_player_test.dart test/features/scenes/fullscreen_mode_test.dart test/features/scenes/video_player_ui_test.dart
```

## Phase 2: Extract Player Settings

Goal:

- Move preference keys and setter persistence out of `PlayerState`.
- Replace repeated state reconstruction with `PlayerSettings` copy/update helpers.

Tasks:

- [ ] Create `PlayerSettings` value object for prefs-backed fields currently stored on `GlobalPlayerState`.
- [ ] Create `PlayerSettingsController` or pure loader/saver helpers around `sharedPreferencesProvider`.
- [ ] Update `PlayerState.build()` to load settings through the new helper.
- [ ] Update settings setters to delegate persistence.
- [ ] Add tests for legacy `autoplay_next` migration to `VideoEndBehavior.next`.

Verification:

```bash
rtk flutter test test/features/scenes/presentation/providers/global_player_state_test.dart test/features/scenes/presentation/providers/playend_behavior_test.dart
```

## Phase 3: Extract Playback Activity Tracking

Goal:

- Move play count, duration accumulation, periodic save timer, resume time save, and scene details refresh out of `PlayerState`.

Tasks:

- [ ] Create `PlaybackActivityTracker` with `start(scene, player)`, `stop(scene: scene, player: player)`, `save(scene: scene, player: player)`, and `dispose()` methods.
- [ ] Inject repository and clock dependencies so tests do not depend on real time.
- [ ] Replace `_startActivityTracking`, `_stopActivityTracking`, and `_saveActivity` calls with tracker calls.
- [ ] Preserve the current 5-second play count and 30-second periodic save behavior.
- [ ] Add unit tests for play count once per scene and duration save on stop.

Verification:

```bash
rtk flutter test test/activity_tracking_test.dart test/features/scenes/presentation/providers/global_player_state_test.dart
```

## Phase 4: Extract Playback Session Lifecycle

Goal:

- Make media-kit player creation, stream opening, subscriptions, borrowed controller handling, and disposal a focused lifecycle unit.

Tasks:

- [ ] Create `PlaybackSessionController`.
- [ ] Move duplicated subscription setup from `playScene` and `attachController` into one helper.
- [ ] Emit small session events: playing changed, buffering changed, dimensions changed, completed, error.
- [ ] Keep `PlayerState` responsible for converting session events into `GlobalPlayerState`.
- [ ] Add tests around borrowed controller disposal and subscription replacement.

Verification:

```bash
rtk flutter test test/features/scenes/presentation/providers/global_player_state_test.dart test/video_playback_test.dart
```

## Phase 5: Extract Fullscreen Controller

Goal:

- Make fullscreen transition state explicit and centralize platform side effects.

Tasks:

- [ ] Add a `PlayerDisplayMode` or replace `PlayerViewMode` with explicit transition states.
- [ ] Create `FullscreenController` for system UI, orientation, desktop window fullscreen, web fullscreen, and restore behavior.
- [ ] Update `GlobalFullscreenOverlay` to render based on mode and call controller transition methods.
- [ ] Update `ShellPage` back handling to dispatch exit-fullscreen instead of manually setting provider fields.
- [ ] Add transition tests for enter, exit, back gesture, and cleanup.

Verification:

```bash
rtk flutter test test/features/scenes/fullscreen_mode_test.dart test/features/scenes/presentation/providers/global_player_state_test.dart
```

## Phase 6: Extract Queue Playback Coordinator

Goal:

- Make next/previous playback transactional and keep queue index, active scene, stream selection, and navigation in sync.

Tasks:

- [ ] Create `QueuePlaybackCoordinator`.
- [ ] Add pure queue target helpers for next/previous scene lookup.
- [ ] Resolve the target stream before mutating queue index.
- [ ] Commit queue index only after `playScene` or the session switch succeeds.
- [ ] Keep fullscreen autoplay in fullscreen and emit background-sync navigation commands only after successful scene switch.
- [ ] Add failure-path tests where target resolution returns null and the queue index remains unchanged.

Verification:

```bash
rtk flutter test test/features/scenes/playback_queue_test.dart test/features/scenes/presentation/providers/playback_queue_state_test.dart test/features/scenes/presentation/providers/playend_behavior_test.dart
```

## Final Verification

Run the focused scene/player suite:

```bash
rtk flutter test test/features/scenes/presentation/widgets/scene_video_player_test.dart test/features/scenes/fullscreen_mode_test.dart test/features/scenes/playback_queue_test.dart test/features/scenes/presentation/providers/playback_queue_state_test.dart test/features/scenes/presentation/providers/playend_behavior_test.dart test/features/scenes/presentation/providers/global_player_state_test.dart test/video_playback_test.dart test/activity_tracking_test.dart
```

Run analyzer for touched files:

```bash
rtk flutter analyze lib/features/scenes/presentation/widgets/player_surface.dart lib/features/scenes/presentation/widgets/scene_video_player.dart lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart lib/features/scenes/presentation/providers/video_player_provider.dart lib/features/scenes/presentation/providers/playback_queue_provider.dart
```

## Rollout Notes

- Commit after each phase.
- Avoid changing playback behavior and architecture in the same commit.
- If a phase exposes an existing bug, add a failing regression test before fixing it.
- Keep the public provider API stable until all call sites are migrated.
