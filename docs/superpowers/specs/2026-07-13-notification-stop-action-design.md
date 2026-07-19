# Notification Stop Action Removal

## Scope

Remove the Stop action from the system media notification. Keep the internal
player stop behavior, media-handler stop callback, and task-removal cleanup.

## Change

- Remove `MediaControl.stop` from `StashMediaHandler.updatePlaybackState`.
- Shift the Next compact-action index from `3` to `2`.
- Add a focused regression assertion that Stop is not published.

## Verification

Run the focused media-handler test, analyzer, and `git diff --check`.

Audio-focus settings are intentionally deferred.
