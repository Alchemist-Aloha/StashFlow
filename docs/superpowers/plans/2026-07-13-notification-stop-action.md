# Notification Stop Action Removal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the Stop action from the Android system media notification without changing internal stop behavior.

**Architecture:** Change only the controls published by `StashMediaHandler`. Preserve its stop callback and task-removal cleanup, and lock the notification contract with one focused test.

**Tech Stack:** Flutter, Dart, `audio_service`, `flutter_test`

## Global Constraints

- Do not change `StashMediaHandler.stop`, `onStopCallback`, `onTaskRemoved`, or `PlayerState.stop`.
- Do not add settings, dependencies, or native Android code.
- Follow `/home/likun/.codex/RTK.md` for every shell command.

---

### Task 1: Remove the published Stop action

**Files:**
- Modify: `test/core/utils/media_handler_test.dart`
- Modify: `lib/core/utils/media_handler.dart`

**Interfaces:**
- Consumes: `StashMediaHandler.updatePlaybackState({required bool isPlaying, ...})`
- Produces: notification controls ordered as Previous, Play/Pause, Next with compact indices `[0, 1, 2]`

- [ ] **Step 1: Write the failing notification-controls test**

Add this test to the `updatePlaybackState` group in `test/core/utils/media_handler_test.dart`:

```dart
test('does not publish a stop control', () {
  handler.updatePlaybackState(isPlaying: true);

  expect(
    handler.playbackState.value.controls,
    [MediaControl.skipToPrevious, MediaControl.pause, MediaControl.skipToNext],
  );
  expect(
    handler.playbackState.value.androidCompactActionIndices,
    [0, 1, 2],
  );
});
```

- [ ] **Step 2: Run the focused test and verify RED**

Run:

```bash
rtk proxy env HOME=/tmp flutter test test/core/utils/media_handler_test.dart
```

Expected: FAIL because the published controls still contain `MediaControl.stop` and the compact indices still contain `3`.

- [ ] **Step 3: Remove only the notification action**

Change the controls and compact indices in `lib/core/utils/media_handler.dart` to:

```dart
controls: [
  MediaControl.skipToPrevious,
  if (isPlaying) MediaControl.pause else MediaControl.play,
  MediaControl.skipToNext,
],
// Which controls to show in Android's compact notification view.
androidCompactActionIndices: const [0, 1, 2],
```

- [ ] **Step 4: Verify GREEN and static analysis**

Run:

```bash
rtk proxy env HOME=/tmp flutter test test/core/utils/media_handler_test.dart
rtk proxy env HOME=/tmp flutter analyze lib/core/utils/media_handler.dart test/core/utils/media_handler_test.dart
rtk git diff --check
```

Expected: test passes, analyzer reports no issues, and `git diff --check` produces no output.

- [ ] **Step 5: Commit the verified change**

```bash
rtk git add docs/superpowers/plans/2026-07-13-notification-stop-action.md test/core/utils/media_handler_test.dart lib/core/utils/media_handler.dart
rtk git commit -m "refactor: remove notification stop action"
```
