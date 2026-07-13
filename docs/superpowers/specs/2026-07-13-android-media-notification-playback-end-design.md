# Android Media Notification and Playback-End Design

## Goal

Keep Android notification-shade media controls synchronized with the active video and remove the notification immediately whenever playback terminates.

## Scope

Retain the existing `audio_service`, `media_kit`, Riverpod player, queue coordinator, and user-selectable `stop`, `loop`, and `next` end behaviors. Do not add dependencies or migrate the player to native Media3.

## Design

`StashMediaHandler` remains the system-media boundary. Its playback update accepts the real processing state, exposes only valid controls, and provides one explicit dismissal operation that publishes an idle, non-playing state and clears the current media item. Removing the Android task stops playback but does not call `SystemNavigator.pop()` after the task is already being removed.

`PlaybackSessionController` treats `player.stream.completed` as an edge: one callback for each transition to `true`, reset after `false` or a new binding. This prevents duplicate completion handling without adding timers.

`PlayerState` remains the end-behavior owner:

- `stop` exits playback through the existing shared stop path and dismisses the notification.
- `loop` seeks to zero and resumes the same player without dismissing the notification.
- `next` preserves fullscreen, resolves and starts the next queue item transactionally, and returns whether it advanced. If no next item exists or resolution/startup fails, playback stops and the notification is dismissed.
- Manual stop uses the same notification dismissal path.
- Notification Previous is wired to the existing `playPrevious()` command.

Artwork loading remains asynchronous, but an artwork result may update metadata only while its scene is still active. A stale downloaded file is deleted instead of replacing the current scene's artwork.

## Error Handling

Queue advancement commits only after the target scene becomes active. Failed or unavailable automatic advancement terminates cleanly. Artwork download failures continue to fall back to text metadata; stale results are silently discarded. Media callbacks remain safe when no player or queue target exists.

## Verification

Focused tests will prove:

- idle state clears the media item and represents notification dismissal;
- notification Previous invokes the player callback;
- task removal stops without requesting a second application pop;
- duplicate completion `true` events trigger once and reset after `false`;
- `stop` dismisses and exits fullscreen;
- `loop` preserves the active scene and restarts playback;
- `next` preserves fullscreen on success and stops when advancement is unavailable;
- failed automatic advancement does not commit the queue index.

Run focused Flutter tests for `media_handler_test.dart`, `playback_session_controller_test.dart`, and `playend_behavior_test.dart`, then analyze all touched Dart files.
