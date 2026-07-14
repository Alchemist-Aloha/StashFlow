# Android Notification True Seeking Design

## Goal

Make the existing Android media-notification progress bar perform exact seeks in the active `media_kit` video while preserving whether playback was paused or playing.

## Root cause

`StashMediaHandler` already advertises `MediaAction.seek` and forwards Android's seek callback. `PlayerState` publishes the notification's media duration only when a scene is first attached. If `media_kit` reports a zero or incomplete duration at that moment, later duration-stream updates never reach the notification. The callback also forwards the requested position without clamping or immediately publishing the accepted position back to the media session.

## Scope

- Keep `audio_service` and the existing Android service configuration.
- Keep notification controls and `MediaAction.seek` unchanged.
- Update only the shared `PlayerState` notification/seek seam.
- Do not add dependencies, native Android code, settings, or a second playback abstraction.

## Design

`PlayerState` will bind `mediaHandler.onSeekCallback` to a private async handler. That handler will:

1. Return when there is no active player.
2. Clamp negative positions to zero and positions beyond a known duration to that duration.
3. Capture the current playing state, await `player.seek`, and restore the captured state if the player changes it during the seek.
4. Immediately publish the accepted target position, current buffer, speed, and processing state to `StashMediaHandler` so Android's progress thumb moves without waiting for a later player event.

The existing duration stream already reaches `_videoListener`. When its real duration differs from the current notification `MediaItem.duration`, `_videoListener` will refresh only the media metadata. It will not refetch artwork or recreate the notification unnecessarily.

## Error handling

No media-session position update is published when `player.seek` fails. A missing player is a no-op, matching the existing remote-control callbacks. The player remains the source of truth after the immediate optimistic notification update; subsequent position events correct any backend rounding or adjustment.

## Verification

Focused provider tests will cover duration arriving after attachment, an out-of-range notification seek being clamped, exact position publication, and preservation of a playing player when a backend pauses during seek. Existing media-handler callback tests remain in place. Run focused Flutter tests, touched-file analysis, formatting, `git diff --check`, and a debug Android APK build when the local Flutter toolchain permits it.
