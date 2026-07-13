# Android Media Notification and Playback-End Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep Android media controls synchronized with playback and remove the notification immediately whenever playback terminates.

**Architecture:** Keep `audio_service` as the system boundary and `PlayerState` as the playback-policy owner. Harden the two existing shared seams: make completion an edge in `PlaybackSessionController`, and make terminal playback explicitly publish an idle/empty media session through `StashMediaHandler`.

**Tech Stack:** Flutter, Dart, Riverpod, `audio_service`, `media_kit`, `flutter_test`, Mockito

## Global Constraints

- Add no dependency and no native Media3 migration.
- Preserve the existing `stop`, `loop`, and `next` user settings.
- Preserve fullscreen during successful next-item playback.
- Commit queue advancement only after the target scene is active.
- Use the existing player, queue coordinator, and media-handler boundaries.

---

### Task 1: Make the media handler lifecycle explicit

**Files:**
- Modify: `test/core/utils/media_handler_test.dart`
- Modify: `lib/core/utils/media_handler.dart`

**Interfaces:**
- Produces: `updatePlaybackState(..., AudioProcessingState processingState)` and `dismiss()`.
- Produces: `updateArtwork({required String id, required String thumbnailUri})`, which updates only the current media item.
- Preserves: existing media command callback fields and overrides.

- [ ] **Step 1: Write failing handler tests**

Add tests that require processing-state propagation, guarded artwork, dismissal, and task-removal behavior:

```dart
test('publishes the supplied processing state', () {
  handler.updatePlaybackState(
    isPlaying: false,
    processingState: AudioProcessingState.buffering,
  );

  expect(
    handler.playbackState.value.processingState,
    AudioProcessingState.buffering,
  );
});

test('ignores artwork for an inactive media item', () {
  handler.updateMetadata(id: 'current', title: 'Current');
  handler.updateArtwork(
    id: 'stale',
    thumbnailUri: 'file:///tmp/stale.jpg',
  );

  expect(handler.mediaItem.value?.id, 'current');
  expect(handler.mediaItem.value?.artUri, isNull);
});

test('dismiss publishes idle state and clears metadata', () {
  handler.updateMetadata(id: '1', title: 'Scene');
  handler.updatePlaybackState(isPlaying: true);

  handler.dismiss();

  expect(handler.playbackState.value.playing, isFalse);
  expect(
    handler.playbackState.value.processingState,
    AudioProcessingState.idle,
  );
  expect(handler.playbackState.value.controls, isEmpty);
  expect(handler.mediaItem.value, isNull);
});
```

Change the task-removal test to assert only the stop callback. Remove the platform-channel mock and its `SystemNavigator.pop` expectation.

- [ ] **Step 2: Run the handler tests and verify RED**

Run:

```bash
rtk proxy 'env HOME=/tmp /home/likun/develop/flutter/bin/flutter test test/core/utils/media_handler_test.dart'
```

Expected: compilation failures because `processingState`, `updateArtwork`, and `dismiss` do not exist.

- [ ] **Step 3: Implement the minimal handler changes**

In `StashMediaHandler`, accept the actual processing state, guard artwork by media ID, centralize terminal state, and stop popping an already-removed task:

```dart
void updatePlaybackState({
  required bool isPlaying,
  Duration? position,
  Duration? bufferedPosition,
  double speed = 1.0,
  AudioProcessingState processingState = AudioProcessingState.ready,
}) {
  playbackState.add(
    PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: processingState,
      playing: isPlaying,
      updatePosition: position ?? Duration.zero,
      bufferedPosition: bufferedPosition ?? Duration.zero,
      speed: speed,
    ),
  );
}

void updateArtwork({required String id, required String thumbnailUri}) {
  final current = mediaItem.value;
  if (current?.id != id) return;
  mediaItem.add(current!.copyWith(artUri: Uri.parse(thumbnailUri)));
}

void dismiss() {
  playbackState.add(
    playbackState.value.copyWith(
      controls: const [],
      systemActions: const {},
      androidCompactActionIndices: const [],
      playing: false,
      processingState: AudioProcessingState.idle,
    ),
  );
  mediaItem.add(null);
}

@override
Future<void> stop() async {
  await onStopCallback?.call();
  dismiss();
}

@override
Future<void> onTaskRemoved() => stop();
```

Remove the now-unused `flutter/services.dart` import.

- [ ] **Step 4: Run the handler tests and verify GREEN**

Run the same focused command. Expected: all `media_handler_test.dart` tests pass.

### Task 2: Deduplicate player completion edges

**Files:**
- Modify: `test/features/scenes/presentation/providers/playback_session_controller_test.dart`
- Modify: `lib/features/scenes/presentation/providers/playback_session_controller.dart`

**Interfaces:**
- Preserves: `bindPlayerStreams(Player, {onTick, onCompleted, onError})`.
- Changes behavior: `onCompleted` fires once for consecutive `true` values and becomes eligible again after `false`.

- [ ] **Step 1: Write the failing edge test**

```dart
test('completed callback fires once per false-to-true edge', () async {
  final sessionController = PlaybackSessionController(
    createPlayer: () => player1,
    createVideoController: (_) => controller1,
  );
  var completed = 0;

  await sessionController.bindPlayerStreams(
    player1,
    onTick: () {},
    onCompleted: () => completed++,
    onError: (_) {},
  );

  completed1.add(true);
  completed1.add(true);
  await Future<void>.delayed(Duration.zero);
  expect(completed, 1);

  completed1.add(false);
  completed1.add(true);
  await Future<void>.delayed(Duration.zero);
  expect(completed, 2);
});
```

- [ ] **Step 2: Run the controller test and verify RED**

```bash
rtk proxy 'env HOME=/tmp /home/likun/develop/flutter/bin/flutter test test/features/scenes/presentation/providers/playback_session_controller_test.dart'
```

Expected: the first count is `2`, proving duplicate completion handling.

- [ ] **Step 3: Implement edge detection in the existing listener**

```dart
var completionHandled = false;
_subscriptions.add(
  player.stream.completed.listen((completed) {
    if (!completed) {
      completionHandled = false;
    } else if (!completionHandled) {
      completionHandled = true;
      onCompleted();
    }
  }),
);
```

- [ ] **Step 4: Run the controller test and verify GREEN**

Run the same focused command. Expected: all controller tests pass.

### Task 3: Synchronize end behavior, queue failure, controls, and artwork

**Files:**
- Modify: `test/features/scenes/presentation/providers/playend_behavior_test.dart`
- Modify: `lib/features/scenes/presentation/providers/video_player_provider.dart`

**Interfaces:**
- Changes: `Future<void> playNext()` to `Future<bool> playNext()`; callers may ignore the result.
- Preserves: `void stop()`, with an optional internal `dismissNotification` named parameter.
- Consumes: `StashMediaHandler.dismiss()` and `updateArtwork()` from Task 1.

- [ ] **Step 1: Write failing end-behavior tests**

Install a real handler in the test global before building the provider and clear it during teardown:

```dart
import 'package:stash_app_flutter/core/utils/media_handler.dart';
import 'package:stash_app_flutter/main.dart' as app;

app.mediaHandler = StashMediaHandler();
// tearDown: app.mediaHandler = null;
```

Strengthen the stop test to require terminal player and notification state:

```dart
expect(container.read(playerStateProvider).activeScene, isNull);
expect(
  app.mediaHandler!.playbackState.value.processingState,
  AudioProcessingState.idle,
);
expect(app.mediaHandler!.mediaItem.value, isNull);
```

Add a loop test:

```dart
test('loop seeks to zero and resumes without stopping', () async {
  final notifier = container.read(playerStateProvider.notifier);
  final scene = createTestScene('1');
  await notifier.attachController(scene, mockPlayer, mockVideoController);
  notifier.setPlayEndBehavior(VideoEndBehavior.loop);

  completedStream.add(true);
  await Future<void>.delayed(Duration.zero);

  verify(mockPlayer.seek(Duration.zero)).called(1);
  verify(mockPlayer.play()).called(1);
  expect(container.read(playerStateProvider).activeScene?.id, '1');
});
```

Add a failed-next test requiring terminal state when the existing `NullStreamResolver` cannot resolve the next item. Add a successful resolver fake returning `const StreamChoice(url: 'https://example.test/2.mp4', mimeType: 'video/mp4')` and require successful Next to advance the queue while preserving fullscreen.

- [ ] **Step 2: Run the end-behavior tests and verify RED**

```bash
rtk proxy 'env HOME=/tmp /home/likun/develop/flutter/bin/flutter test test/features/scenes/presentation/providers/playend_behavior_test.dart'
```

Expected: stop retains the active scene, failed Next does not terminate, and the notification is not idle.

- [ ] **Step 3: Implement the minimal shared lifecycle changes**

Wire Previous and avoid double dismissal for a notification-originated stop:

```dart
mediaHandler?.onStopCallback = () async => stop(dismissNotification: false);
mediaHandler?.onSkipToNextCallback = () async {
  await playNext();
};
mediaHandler?.onSkipToPreviousCallback = () async {
  await playPrevious();
};
```

Make text metadata immediate, then enhance only the active scene with a uniquely-created temporary artwork file:

```dart
mediaHandler?.updateMetadata(
  id: scene.id,
  title: scene.title,
  studio: scene.studioName,
  duration: duration,
);
if (screenshotUrl == null || screenshotUrl.isEmpty || isTestMode) return;
unawaited(_fetchAndUpdateArt(scene, screenshotUrl));
```

Inside the artwork fetch, create a scene- and timestamp-specific file in `getTemporaryDirectory()`, delete a stale result, then call `updateArtwork(id: scene.id, thumbnailUri: ...)` only after confirming `state.activeScene?.id == scene.id`.

Make stop publish terminal state through the shared handler:

```dart
void stop({bool dismissNotification = true}) {
  // Existing cast, disposal, wakelock, and state reset logic stays here.
  if (dismissNotification) mediaHandler?.dismiss();
}
```

Make completion asynchronous without exposing an unhandled future:

```dart
void _handleVideoFinished() {
  final completedSceneId = state.activeScene?.id;
  if (completedSceneId != null) {
    unawaited(_applyVideoEndBehavior(completedSceneId));
  }
}

Future<void> _applyVideoEndBehavior(String completedSceneId) async {
  if (state.activeScene?.id != completedSceneId) return;

  switch (state.playEndBehavior) {
    case VideoEndBehavior.stop:
      stop();
      return;
    case VideoEndBehavior.loop:
      await state.player?.seek(Duration.zero);
      await state.player?.play();
      return;
    case VideoEndBehavior.next:
      if (state.streamSource == 'tiktok-promotion') return;
      if (_isTransitioning) return;
      if (!await playNext() && state.activeScene?.id == completedSceneId) {
        stop();
      }
  }
}
```

Return `false` from every unavailable/failure path in `playNext()` and return whether the target scene became active after transactional startup. Keep queue index and navigation commits behind that same success check. Before treating `false` as terminal, verify no queue transition is already in flight and the completed scene is still active.

- [ ] **Step 4: Run all focused tests and verify GREEN**

```bash
rtk proxy 'env HOME=/tmp /home/likun/develop/flutter/bin/flutter test test/core/utils/media_handler_test.dart test/features/scenes/presentation/providers/playback_session_controller_test.dart test/features/scenes/presentation/providers/playend_behavior_test.dart'
```

Expected: all focused tests pass.

- [ ] **Step 5: Format and analyze touched code**

```bash
rtk proxy 'env HOME=/tmp /home/likun/develop/flutter/bin/dart format lib/core/utils/media_handler.dart lib/features/scenes/presentation/providers/playback_session_controller.dart lib/features/scenes/presentation/providers/video_player_provider.dart test/core/utils/media_handler_test.dart test/features/scenes/presentation/providers/playback_session_controller_test.dart test/features/scenes/presentation/providers/playend_behavior_test.dart'
rtk proxy 'env HOME=/tmp /home/likun/develop/flutter/bin/flutter analyze lib/core/utils/media_handler.dart lib/features/scenes/presentation/providers/playback_session_controller.dart lib/features/scenes/presentation/providers/video_player_provider.dart test/core/utils/media_handler_test.dart test/features/scenes/presentation/providers/playback_session_controller_test.dart test/features/scenes/presentation/providers/playend_behavior_test.dart'
```

Expected: formatting succeeds and analysis reports no issues.

- [ ] **Step 6: Review the final diff and commit**

```bash
rtk git diff --check
rtk git diff --stat
rtk git add lib/core/utils/media_handler.dart lib/features/scenes/presentation/providers/playback_session_controller.dart lib/features/scenes/presentation/providers/video_player_provider.dart test/core/utils/media_handler_test.dart test/features/scenes/presentation/providers/playback_session_controller_test.dart test/features/scenes/presentation/providers/playend_behavior_test.dart docs/superpowers/plans/2026-07-13-android-media-notification-playback-end.md
rtk git commit -m "fix: synchronize media notification playback lifecycle"
```
