# Background Playback Lifecycle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Background Playback off explicitly pause the global Android player while preserving native PiP and task-removal stop behavior.

**Architecture:** `PlayerState` owns global lifecycle decisions. It pauses when background playback is off, schedules the existing recovery when it is on, and requests native PiP before applying either fallback policy. The global video surface disables `media_kit_video`'s independent lifecycle pause so two observers cannot compete; local preview players remain unchanged.

**Tech Stack:** Dart, Flutter, Riverpod, `media_kit`, `media_kit_video`, `audio_service`, Flutter widget tests, Mockito.

## Global Constraints

- Keep native Android PiP independent from Background Playback.
- Preserve `StashMediaHandler.onTaskRemoved`, which stops and dismisses the media session.
- Do not add dependencies or change the persisted setting key.
- Follow the repository rule to run focused tests or a Flutter build when the SDK is available.

---

### Task 1: Add the failing background-off regression test

**Files:**
- Modify: `/home/likun/StashFlow/test/features/scenes/presentation/providers/playend_behavior_test.dart`

**Interfaces:**
- Consumes: `PlayerState.didChangeAppLifecycleState`, the existing mocked player/controller setup, and `setEnableBackgroundPlayback`.
- Produces: A regression test proving an active player receives `pause()` on `AppLifecycleState.hidden` when the setting is off.

- [ ] **Step 1: Write the failing test**

Add this test after the existing `createTestScene` helper:

```dart
  test('background playback off pauses an active player', () async {
    final notifier = container.read(playerStateProvider.notifier);
    final scene = createTestScene('background-off');

    when(mockPlayer.state).thenReturn(PlayerStateData(playing: true));
    await notifier.attachController(scene, mockPlayer, mockVideoController);
    notifier.setEnableBackgroundPlayback(false);

    notifier.didChangeAppLifecycleState(AppLifecycleState.hidden);

    verify(mockPlayer.pause()).called(1);
    expect(container.read(playerStateProvider).isPlaying, isFalse);
  });
```

- [ ] **Step 2: Run the focused test and verify it fails for the missing behavior**

Run:

```bash
rtk flutter test test/features/scenes/presentation/providers/playend_behavior_test.dart --plain-name "background playback off pauses an active player"
```

Expected: the test fails because the current lifecycle handler returns without calling `pause()` when `enableBackgroundPlayback` is false.

### Task 2: Centralize global lifecycle policy and preserve PiP

**Files:**
- Modify: `/home/likun/StashFlow/lib/features/scenes/presentation/providers/video_player_provider.dart`
- Modify: `/home/likun/StashFlow/lib/features/scenes/presentation/widgets/native_video_controls.dart`
- Modify: `/home/likun/StashFlow/lib/features/scenes/presentation/widgets/transformable_video_surface.dart`

**Interfaces:**
- Consumes: `PlayerState.didChangeAppLifecycleState`, `requestEnterPip`, `PipMode.isInPipMode`, and the existing background recovery state.
- Produces: A single lifecycle path that either preserves playback through PiP/recovery or pauses the global player.

- [ ] **Step 1: Add the minimal provider policy helpers**

In `PlayerState`, add helpers adjacent to the existing lifecycle methods:

```dart
  bool _canEnterBackgroundPip(Player player) {
    return !kIsWeb &&
        Platform.isAndroid &&
        state.enableNativePip &&
        state.isFullScreen &&
        !state.isInPipMode &&
        !PipMode.isInPipMode.value &&
        player.state.playing;
  }

  void _applyBackgroundPlaybackPolicy(Player player) {
    if (!ref.mounted || state.player != player || !player.state.playing) return;

    if (state.enableBackgroundPlayback) {
      _scheduleBackgroundPlaybackRecovery();
    } else {
      pause(suppressBackgroundRecovery: true);
    }
  }

  void _requestBackgroundPipOrApplyPolicy(Player player) {
    if (_pipRequestInFlight || state.isInPipMode || PipMode.isInPipMode.value) {
      return;
    }

    final elapsedSinceLast = _lastPipRequestAt == null
        ? null
        : DateTime.now().difference(_lastPipRequestAt!);
    if (elapsedSinceLast != null && elapsedSinceLast < _pipRequestCooldown) {
      return;
    }

    final width = player.state.width;
    final height = player.state.height;
    final aspect = (width != null && height != null && height > 0)
        ? width / height
        : 16 / 9;

    unawaited(() async {
      final enteredPip = await requestEnterPip(aspectRatio: aspect);
      if (!ref.mounted || state.player != player || !player.state.playing) {
        return;
      }
      if (enteredPip || state.isInPipMode || PipMode.isInPipMode.value) return;
      _applyBackgroundPlaybackPolicy(player);
    }());
  }
```

- [ ] **Step 2: Route background lifecycle events through the helpers**

Replace the current early-return branch in `didChangeAppLifecycleState` with this policy after `_backgroundEnteredAt` is set:

```dart
    final player = this.state.player;
    if (player == null || !player.state.playing) return;

    final canEnterPip = _canEnterBackgroundPip(player);
    if (canEnterPip &&
        (state == AppLifecycleState.hidden ||
            state == AppLifecycleState.paused)) {
      _requestBackgroundPipOrApplyPolicy(player);
      return;
    }

    _applyBackgroundPlaybackPolicy(player);
```

- [ ] **Step 3: Remove the duplicate PiP lifecycle observer**

In `NativeVideoControls`, remove the `WidgetsBindingObserver` mixin, the `WidgetsBinding.instance.addObserver(this)` and matching removal, and its `didChangeAppLifecycleState` override. Keep its explicit keyboard/button PiP action unchanged.

- [ ] **Step 4: Disable package-level lifecycle pausing for the global surface**

In `TransformableVideoSurface`, pass `pauseUponEnteringBackgroundMode: false` to its `Video` widget. This surface is controlled by `PlayerState`; local preview `Video` widgets are not changed.

- [ ] **Step 5: Run the focused regression test and verify it passes**

Run:

```bash
rtk flutter test test/features/scenes/presentation/providers/playend_behavior_test.dart --plain-name "background playback off pauses an active player"
```

Expected: PASS.

### Task 3: Run focused verification and inspect the diff

**Files:**
- No additional files.

- [ ] **Step 1: Run the affected test files**

```bash
rtk flutter test test/features/scenes/presentation/providers/playend_behavior_test.dart test/core/utils/media_handler_test.dart
```

- [ ] **Step 2: Run static checks when available**

```bash
rtk flutter analyze
```

- [ ] **Step 3: Check formatting and diff scope**

```bash
rtk dart format lib/features/scenes/presentation/providers/video_player_provider.dart lib/features/scenes/presentation/widgets/native_video_controls.dart lib/features/scenes/presentation/widgets/transformable_video_surface.dart test/features/scenes/presentation/providers/playend_behavior_test.dart
rtk git diff --check
rtk git status --short
```

Expected: only the four implementation/test files and the approved plan/spec documentation are changed; no dependency or localization files change.
