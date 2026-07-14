# Background Playback Lifecycle Design

**Goal:** Make Background Playback off explicitly pause the global video when the Android app is backgrounded, while keeping native Android PiP independent.

## Current behavior and root cause

The setting is persisted in `PlayerSettingsStore` and copied into `GlobalPlayerState`. `PlayerState` only schedules keep-alive recovery when the setting is on; it does not explicitly pause when the setting is off. The shared `Video` widget currently pauses itself on Android lifecycle `paused`/`detached` events, which leaves the policy split between the widget and `PlayerState`. Native PiP is requested independently by `NativeVideoControls`, creating a lifecycle-ordering risk if the provider also starts pausing.

## Decision

Make `PlayerState` the lifecycle owner for the global player:

- Background Playback on keeps the existing recovery behavior.
- Background Playback off explicitly pauses on `hidden`, `paused`, and `detached` transitions when the player is not in native PiP.
- Native Android PiP takes precedence over the background setting and keeps playback running.
- Android task removal continues to stop the media session through `StashMediaHandler.onTaskRemoved`.
- The global `Video` surface will not run its own background pause logic; this avoids two components competing over the same player.
- Local preview players outside the global player remain unchanged.

PiP entry will be requested from the provider lifecycle path rather than from `NativeVideoControls`. If PiP entry fails, the provider applies the selected background policy: pause when off, or schedule recovery when on.

## Files

- Modify `lib/features/scenes/presentation/providers/video_player_provider.dart` to centralize lifecycle policy and coordinate PiP fallback.
- Modify `lib/features/scenes/presentation/widgets/native_video_controls.dart` to remove its duplicate lifecycle observer.
- Modify `lib/features/scenes/presentation/widgets/transformable_video_surface.dart` to disable package-level background pausing for the global surface.
- Modify `test/features/scenes/presentation/providers/playend_behavior_test.dart` with a regression test proving background-off pauses an active player.

## Verification

Run the focused provider test and the existing media-handler tests. The focused regression must fail before the provider change because the current background-off path does not call `pause()`, then pass after the change. Inspect the final diff for unrelated changes and run `flutter analyze` if the Flutter SDK is available.

## Non-goals

- No new dependency or Android service is introduced.
- No change to local preview-video lifecycle behavior.
- No change to the user-facing setting or its persisted key.
