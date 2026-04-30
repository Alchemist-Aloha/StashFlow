# Remove Video Middle Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the `video_player` adapter middle layer entirely and refactor UI and state to consume `media_kit` directly.

**Architecture:** We are directly connecting `media_kit`'s `Player` and `VideoController` instances to our existing Riverpod `PlayerState` and UI components. UI components will subscribe to `player.stream` manually in `initState` to trigger `setState()` instead of relying on a monolithic `ValueNotifier`.

**Tech Stack:** Flutter, media_kit, media_kit_video, Riverpod

---

### Task 1: Refactor `GlobalPlayerState` and `PlayerState`

**Files:**
- Modify: `lib/features/scenes/presentation/providers/video_player_provider.dart`

- [ ] **Step 1: Replace imports and update `GlobalPlayerState`**

Remove `import '../../../../core/presentation/video/app_video_controller.dart';`.
Add:
```dart
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
```

In `GlobalPlayerState`:
Replace `final AppVideoController? videoPlayerController;` with:
```dart
  final Player? player;
  final VideoController? videoController;
```
Update the constructor and `copyWith` method to accept and assign `player` and `videoController` instead of `videoPlayerController`.

- [ ] **Step 2: Update `PlayerState` member variables**

Replace `AppVideoController? _videoControllerRef;` with:
```dart
  Player? _playerRef;
  VideoController? _videoControllerRef;
  final List<StreamSubscription> _subscriptions = [];
```

- [ ] **Step 3: Update `playScene` initialization logic**

In `playScene`, instead of `MediaKitVideoControllerAdapter.networkUrl`:
```dart
    final player = Player();
    final videoController = VideoController(player);
    _playerRef = player;
    _videoControllerRef = videoController;
    _activeSceneRef = scene;
    _firstFrameLoggedSceneId = null;
    _lastIsPlaying = null;
    
    // ... update state initialization to pass player and videoController
```

Replace `await videoController.initialize();` and surrounding logic with:
```dart
      await player.open(
        Media(effectiveStreamUrl, httpHeaders: httpHeaders ?? const <String, String>{}),
        play: false,
      );
      
      if (subtitleUrl != null && subtitleUrl.isNotEmpty) {
        await player.setSubtitleTrack(SubtitleTrack.uri(subtitleUrl));
      } else {
        await player.setSubtitleTrack(SubtitleTrack.no());
      }
```
Update `seekTo` logic: `await player.seek(initialPosition!);`

Replace `videoController.addListener(_videoListener);` with:
```dart
      _subscriptions.add(player.stream.playing.listen((_) => _videoListener()));
      _subscriptions.add(player.stream.position.listen((_) => _videoListener()));
      _subscriptions.add(player.stream.duration.listen((_) => _videoListener()));
```

- [ ] **Step 4: Update internal methods interacting with the player**

In `setVolume`, `toggleMute`, etc., use `state.player?.setVolume(...)`.
In `togglePlayPause`, `seekRelative`, use `state.player?.play()`, `state.player?.pause()`, `state.player?.seek(...)`.

In `_videoListener`, replace `controller.value.isPlaying` with `player.state.playing`. Replace `.position` with `.state.position`, `.duration` with `.state.duration`, `.buffered` with `.state.buffer`.

In `_disposeControllers`, clean up:
```dart
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    
    if (_playerRef != null) {
      if (!_isUsingBorrowedController) {
        await _playerRef!.dispose();
      }
    }
    _playerRef = null;
    _videoControllerRef = null;
```

### Task 2: Refactor `TransformableVideoSurface`

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/transformable_video_surface.dart`

- [ ] **Step 1: Update imports and fields**

Remove imports for `app_video_controller.dart` and `app_video_surface.dart`.
Add:
```dart
import 'package:media_kit_video/media_kit_video.dart';
```
Change `final AppVideoController controller;` to `final VideoController controller;`.

- [ ] **Step 2: Update `build` method**

Replace `AppVideoSurface(controller: widget.controller)` with `Video(controller: widget.controller)`.
Replace `widget.controller.value.size.width` with `widget.controller.player.state.width?.toDouble() ?? 0.0`. Same for height.

### Task 3: Refactor `SceneVideoPlayer`

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_video_player.dart`

- [ ] **Step 1: Update imports**
Remove `app_video_controller.dart`.
Add:
```dart
import 'package:media_kit_video/media_kit_video.dart';
```

- [ ] **Step 2: Update field access and subscriptions**

Change `controller = playerState.videoPlayerController` to `controller = playerState.videoController`.
For `aspectRatio`, check `controller?.player.state.width` and `controller?.player.state.height`.
Replace `controller == null || !controller.value.isInitialized` with `controller == null || controller.player.state.width == null`.

For `SceneSubtitleOverlay`, replace `ValueListenableBuilder` with:
```dart
StreamBuilder<List<String>>(
  stream: controller.player.stream.subtitle,
  builder: (context, snapshot) {
    final captionText = snapshot.data?.join('\n') ?? '';
    return SceneSubtitleOverlay(text: captionText, ...);
  }
)
```

Apply similar logic in `FullscreenPlayerPage`.

### Task 4: Refactor `NativeVideoControls`

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/native_video_controls.dart`

- [ ] **Step 1: Update imports and fields**
Remove `app_video_controller.dart`.
Add:
```dart
import 'package:media_kit_video/media_kit_video.dart';
```
Change `final AppVideoController controller;` to `final VideoController controller;`.

- [ ] **Step 2: Add stream subscriptions**

Add a list of subscriptions:
```dart
final List<StreamSubscription> _subscriptions = [];
```
In `initState`, instead of `widget.controller.addListener`, do:
```dart
    _subscriptions.add(widget.controller.player.stream.playing.listen((_) => _onVideoTick()));
    _subscriptions.add(widget.controller.player.stream.position.listen((_) => _onVideoTick()));
    _subscriptions.add(widget.controller.player.stream.duration.listen((_) => _onVideoTick()));
    _wasPlaying = widget.controller.player.state.playing;
```
Cancel subscriptions in `dispose()`.

- [ ] **Step 3: Update `_onVideoTick` and player state accesses**

Replace `widget.controller.value.isPlaying` with `widget.controller.player.state.playing`.
Replace `widget.controller.value.position` with `widget.controller.player.state.position`.
Replace `widget.controller.value.duration` with `widget.controller.player.state.duration`.
Replace `widget.controller.seekTo(...)` with `widget.controller.player.seek(...)`.
Replace `widget.controller.play()` with `widget.controller.player.play()`.
Replace `widget.controller.pause()` with `widget.controller.player.pause()`.

### Task 5: Refactor Secondary UI Components

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/video_controls/video_playback_controls.dart`
- Modify: `lib/features/scenes/presentation/widgets/tiktok_scenes_view.dart` (if applicable)

- [ ] **Step 1: Update `VideoPlaybackControls`**

Replace `AppVideoController` with `VideoController`. Update `widget.controller.setPlaybackSpeed(speed)` to `widget.controller.player.setRate(speed)`.

- [ ] **Step 2: Update `tiktok_scenes_view.dart`**

If it references `AppVideoController`, update it to `VideoController`. Same stream substitution pattern as in `NativeVideoControls` if it listens to state.

### Task 6: Cleanup and Tests

**Files:**
- Delete: `lib/core/presentation/video/app_video_controller.dart`
- Delete: `lib/core/presentation/video/app_video_surface.dart`
- Delete: `test/features/scenes/presentation/widgets/transformable_video_surface_test.dart` (or update to mock VideoController)
- Update: other tests referencing `AppVideoController`.

- [ ] **Step 1: Delete middle layer files**
```bash
rm lib/core/presentation/video/app_video_controller.dart
rm lib/core/presentation/video/app_video_surface.dart
```

- [ ] **Step 2: Update Tests**
Check `test/` directory for `AppVideoController`. Replace them with mock `Player` or `VideoController`. Ensure tests compile and pass.

- [ ] **Step 3: Commit**
```bash
git add .
git commit -m "refactor: remove video player middle layer"
```
