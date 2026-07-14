# Android Notification True Seeking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing Android media-notification progress bar seek the active video exactly while preserving play/pause state.

**Architecture:** Keep `audio_service` as the Android media-session boundary and `PlayerState` as the playback owner. Refresh notification duration from the existing `media_kit` duration stream and route remote seeks through one private `PlayerState` callback that clamps, awaits, restores playback state when needed, and immediately republishes the accepted position.

**Tech Stack:** Flutter, Dart, Riverpod, `audio_service`, `media_kit`, `flutter_test`, Mockito.

## Global Constraints

- Do not add dependencies or native Android code.
- Keep `StashMediaHandler`'s existing `MediaAction.seek` system action and notification controls.
- Clamp negative seeks to `Duration.zero`; clamp only against a known positive player duration.
- Preserve the player's pre-seek playing/paused state.
- Publish the accepted target only after `player.seek` succeeds; later player events remain authoritative.
- Refresh duration metadata without refetching notification artwork.
- Use `rtk` for every shell command and `rtk proxy env HOME=/tmp` for Flutter/Dart commands that write caches.

---

### Task 1: Add failing notification-seeking regression tests

**Files:**
- Modify: `test/features/scenes/presentation/providers/playend_behavior_test.dart`

**Interfaces:**
- Consumes: `app.mediaHandler`, `PlayerState.attachController`, `durationStream`, and the existing generated `MockPlayer`.
- Produces: regression coverage for delayed duration metadata, clamped notification seeks, immediate position publication, and playing-state preservation.

- [ ] **Step 1: Add a delayed-duration metadata test**

Add this test after the existing notification previous test. It starts with an unknown duration, then emits the real duration through the already-bound player stream:

```dart
test('notification duration refreshes when the player discovers it', () async {
  final notifier = container.read(playerStateProvider.notifier);
  final scene = createTestScene('duration');

  when(mockPlayer.state).thenReturn(
    PlayerStateData(duration: Duration.zero),
  );
  await notifier.attachController(scene, mockPlayer, mockVideoController);
  expect(app.mediaHandler!.mediaItem.value?.duration, Duration.zero);

  const duration = Duration(minutes: 2);
  when(mockPlayer.state).thenReturn(PlayerStateData(duration: duration));
  durationStream.add(duration);
  await Future<void>.delayed(Duration.zero);

  expect(app.mediaHandler!.mediaItem.value?.duration, duration);
});
```

- [ ] **Step 2: Add a failing clamped-seek and immediate-sync test**

Add this test to the same file:

```dart
test('notification seek clamps to duration and publishes the target', () async {
  final notifier = container.read(playerStateProvider.notifier);
  final scene = createTestScene('seek');
  const duration = Duration(seconds: 60);

  when(mockPlayer.state).thenReturn(
    PlayerStateData(
      position: const Duration(seconds: 10),
      duration: duration,
    ),
  );
  await notifier.attachController(scene, mockPlayer, mockVideoController);

  await app.mediaHandler!.seek(const Duration(seconds: 120));

  verify(mockPlayer.seek(duration)).called(1);
  verifyNever(mockPlayer.play());
  verifyNever(mockPlayer.pause());
  expect(app.mediaHandler!.playbackState.value.updatePosition, duration);
});
```

- [ ] **Step 3: Add a playing-state preservation test**

Add a test that simulates a player backend pausing while the seek is performed:

```dart
test('notification seek restores playback when a playing player pauses', () async {
  final notifier = container.read(playerStateProvider.notifier);
  final scene = createTestScene('playing-seek');
  var isPlaying = true;
  const duration = Duration(seconds: 60);

  when(mockPlayer.state).thenAnswer(
    (_) => PlayerStateData(
      playing: isPlaying,
      position: const Duration(seconds: 10),
      duration: duration,
    ),
  );
  when(mockPlayer.seek(any)).thenAnswer((_) async => isPlaying = false);
  when(mockPlayer.play()).thenAnswer((_) async => isPlaying = true);
  await notifier.attachController(scene, mockPlayer, mockVideoController);

  await app.mediaHandler!.seek(const Duration(seconds: 30));

  verify(mockPlayer.seek(const Duration(seconds: 30))).called(1);
  verify(mockPlayer.play()).called(1);
  verifyNever(mockPlayer.pause());
});
```

- [ ] **Step 4: Run the focused tests and verify RED**

Run:

```bash
rtk proxy env HOME=/tmp flutter test test/features/scenes/presentation/providers/playend_behavior_test.dart
```

Expected: the new duration and seek assertions fail because duration metadata is not refreshed and the callback forwards the raw position without immediate synchronization or clamping.

---

### Task 2: Synchronize duration metadata and notification seeks

**Files:**
- Modify: `lib/features/scenes/presentation/providers/video_player_provider.dart:340-343,416-421,1518-1617`

**Interfaces:**
- Consumes: `StashMediaHandler.onSeekCallback`, `Player.stream.duration`, and `Player.state`.
- Produces: private `Future<void> _seekFromMediaNotification(Duration position)` behavior and refreshed `MediaItem.duration` for the active scene.

- [ ] **Step 1: Bind the shared seek callback**

Replace the direct callback assignment:

```dart
mediaHandler?.onSeekCallback = _seekFromMediaNotification;
```

- [ ] **Step 2: Add the minimal seek handler**

Add this method near `_handleMediaPauseCommand`:

```dart
  Future<void> _seekFromMediaNotification(Duration position) async {
    final player = state.player;
    if (player == null) return;

    final beforeSeek = player.state;
    final duration = beforeSeek.duration;
    var target = position < Duration.zero ? Duration.zero : position;
    if (duration > Duration.zero && target > duration) {
      target = duration;
    }

    await player.seek(target);

    if (beforeSeek.playing != player.state.playing) {
      if (beforeSeek.playing) {
        await player.play();
      } else {
        await player.pause();
      }
    }

    final afterSeek = player.state;
    _lastMediaHandlerPosition = target;
    mediaHandler?.updatePlaybackState(
      isPlaying: afterSeek.playing,
      position: target,
      bufferedPosition: afterSeek.buffer,
      speed: afterSeek.rate,
      processingState: afterSeek.buffering
          ? AudioProcessingState.buffering
          : AudioProcessingState.ready,
    );
  }
```

- [ ] **Step 3: Refresh duration only when it changes**

Inside `_videoListener`, after reading `currentPosition`, add:

```dart
      final currentDuration = player.state.duration;
      final activeScene = state.activeScene;
      final currentMediaItem = mediaHandler?.mediaItem.value;
      if (activeScene != null &&
          currentMediaItem?.id == activeScene.id &&
          currentMediaItem?.duration != currentDuration) {
        mediaHandler?.updateMetadata(
          id: activeScene.id,
          title: activeScene.title,
          studio: activeScene.studioName,
          duration: currentDuration,
        );
      }
```

Do not call `_updateMediaNotification` here; that would refetch artwork on every duration event.

- [ ] **Step 4: Format the touched Dart files**

Run:

```bash
rtk proxy env HOME=/tmp dart format lib/features/scenes/presentation/providers/video_player_provider.dart test/features/scenes/presentation/providers/playend_behavior_test.dart
```

Expected: both files format successfully with no unrelated file changes.

- [ ] **Step 5: Run the focused tests and verify GREEN**

Run:

```bash
rtk proxy env HOME=/tmp flutter test test/features/scenes/presentation/providers/playend_behavior_test.dart test/core/utils/media_handler_test.dart
```

Expected: all focused tests pass, including delayed duration publication, bounded seeking, exact immediate position publication, and play/pause preservation.

---

### Task 3: Verify the Android-facing change

**Files:**
- No additional source files.

- [ ] **Step 1: Analyze touched Dart files**

Run:

```bash
rtk proxy env HOME=/tmp flutter analyze lib/features/scenes/presentation/providers/video_player_provider.dart test/features/scenes/presentation/providers/playend_behavior_test.dart lib/core/utils/media_handler.dart test/core/utils/media_handler_test.dart
```

Expected: `No issues found!`.

- [ ] **Step 2: Run the broader focused scene-provider tests**

Run:

```bash
rtk proxy env HOME=/tmp flutter test test/features/scenes/presentation/providers
```

Expected: all scene-provider tests pass.

- [ ] **Step 3: Build a debug Android APK**

Run:

```bash
rtk proxy env HOME=/tmp flutter build apk --debug --no-tree-shake-icons
```

Expected: the debug APK builds successfully. If the local Android SDK/toolchain blocks the build, retain the exact failure and report it separately from passing Dart verification.

- [ ] **Step 4: Check the final diff**

Run:

```bash
rtk git diff --check
rtk git diff --stat
rtk git status --short
```

Expected: no whitespace errors, only the approved spec/plan/source/test files changed, and no generated or cache files are included.
