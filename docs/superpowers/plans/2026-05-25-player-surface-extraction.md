# PlayerSurface Extraction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract the duplicated inline/fullscreen video rendering surface into one `PlayerSurface` widget.

**Architecture:** Keep playback ownership and fullscreen platform effects in their current parent widgets. Move shared rendering concerns into `PlayerSurface`: transform state, buffering spinner debounce, casting placeholder, `TransformableVideoSurface`, subtitle options, loading overlay, and `NativeVideoControls`.

**Tech Stack:** Flutter, Riverpod, media_kit_video, vector_math, cast service provider, existing `NativeVideoControls` and `TransformableVideoSurface`.

---

## File Structure

- Create: `lib/features/scenes/presentation/widgets/player_surface.dart`
  - New shared widget for active video rendering.
- Modify: `lib/features/scenes/presentation/widgets/scene_video_player.dart`
  - Remove duplicated rendering state and active surface stack; delegate to `PlayerSurface`.
- Modify: `lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart`
  - Remove duplicated rendering state and active surface stack; delegate to `PlayerSurface`.
- Test: `test/features/scenes/presentation/widgets/scene_video_player_test.dart`
  - Existing placeholder/autoplay tests should remain green.
- Test: `test/features/scenes/fullscreen_mode_test.dart`
  - Existing overlay visibility test should remain green.
- Optional Test: `test/features/scenes/presentation/widgets/player_surface_test.dart`
  - Add only if a lightweight controller-free test can cover a pure helper or fallback state. Do not mock media-kit internals heavily for this first step.

## Task 1: Create `PlayerSurface` Skeleton

**Files:**
- Create: `lib/features/scenes/presentation/widgets/player_surface.dart`

- [ ] **Step 1: Create the widget API**

Add a `ConsumerStatefulWidget` with the same data both parents already have available:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/services/cast_service.dart';
import '../../domain/entities/scene.dart';
import '../providers/video_player_provider.dart';
import 'native_video_controls.dart';
import 'transformable_video_surface.dart';

TextAlign _subtitleTextAlign(String setting) {
  switch (setting) {
    case 'left':
      return TextAlign.left;
    case 'right':
      return TextAlign.right;
    case 'center':
    default:
      return TextAlign.center;
  }
}

class PlayerSurface extends ConsumerStatefulWidget {
  const PlayerSurface({
    required this.scene,
    required this.controller,
    required this.onFullScreenToggle,
    this.fit = BoxFit.contain,
    this.squareFit = BoxFit.contain,
    super.key,
  });

  final Scene scene;
  final VideoController controller;
  final VoidCallback onFullScreenToggle;
  final BoxFit fit;
  final BoxFit squareFit;

  @override
  ConsumerState<PlayerSurface> createState() => _PlayerSurfaceState();
}
```

- [ ] **Step 2: Add transform and buffering state**

Add state fields and lifecycle cleanup:

```dart
class _PlayerSurfaceState extends ConsumerState<PlayerSurface> {
  Timer? _bufferingDisplayTimer;
  bool _showBufferingSpinner = false;

  final ValueNotifier<Matrix4> _transformationNotifier = ValueNotifier(
    Matrix4.identity(),
  );
  double _lastScale = 1.0;
  double _lastRotation = 0.0;

  @override
  void dispose() {
    _bufferingDisplayTimer?.cancel();
    _transformationNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlayerSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.id != widget.scene.id ||
        oldWidget.controller != widget.controller) {
      _bufferingDisplayTimer?.cancel();
      _bufferingDisplayTimer = null;
      _showBufferingSpinner = false;
      _transformationNotifier.value = Matrix4.identity();
      _lastScale = 1.0;
      _lastRotation = 0.0;
    }
  }
}
```

- [ ] **Step 3: Run formatter**

Run:

```bash
rtk dart format lib/features/scenes/presentation/widgets/player_surface.dart
```

Expected: formatter succeeds.

## Task 2: Move Shared Gesture and Loading Logic

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/player_surface.dart`

- [ ] **Step 1: Add transform handlers**

Add these methods inside `_PlayerSurfaceState`:

```dart
void _onScaleStart(ScaleStartDetails details) {
  _lastScale = 1.0;
  _lastRotation = 0.0;
}

void _onScaleUpdate(ScaleUpdateDetails details) {
  if (details.pointerCount < 2) return;

  final double deltaScale = details.scale / _lastScale;
  final double deltaRotation = details.rotation - _lastRotation;
  final Offset focalPoint = details.localFocalPoint;

  final Matrix4 matrix = Matrix4.identity()
    ..translateByVector3(Vector3(focalPoint.dx, focalPoint.dy, 0))
    ..rotateZ(deltaRotation)
    ..scaleByVector3(Vector3(deltaScale, deltaScale, 1.0))
    ..translateByVector3(Vector3(-focalPoint.dx, -focalPoint.dy, 0))
    ..translateByVector3(
      Vector3(details.focalPointDelta.dx, details.focalPointDelta.dy, 0),
    );

  _transformationNotifier.value = matrix * _transformationNotifier.value;
  _lastScale = details.scale;
  _lastRotation = details.rotation;
}

void _onTransformationDelta(Matrix4 delta, Offset focalPoint) {
  _transformationNotifier.value = delta * _transformationNotifier.value;
}
```

- [ ] **Step 2: Add buffering debounce helper**

Add this helper inside `_PlayerSurfaceState`:

```dart
bool _updateAndReadLoadingState(GlobalPlayerState playerState) {
  final videoWidth = playerState.videoWidth;
  final videoHeight = playerState.videoHeight;
  final isVideoReady =
      videoWidth != null && videoHeight != null && videoHeight > 0;

  if (playerState.isBuffering && !_showBufferingSpinner) {
    _bufferingDisplayTimer ??= Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showBufferingSpinner = true);
    });
  } else if (!playerState.isBuffering && _showBufferingSpinner) {
    _bufferingDisplayTimer?.cancel();
    _bufferingDisplayTimer = null;
    Future.microtask(() {
      if (mounted) setState(() => _showBufferingSpinner = false);
    });
  } else if (!playerState.isBuffering) {
    _bufferingDisplayTimer?.cancel();
    _bufferingDisplayTimer = null;
  }

  return _showBufferingSpinner || (!isVideoReady && !playerState.isPlaying);
}
```

- [ ] **Step 3: Run analyzer on the new file**

Run:

```bash
rtk flutter analyze lib/features/scenes/presentation/widgets/player_surface.dart
```

Expected: no analyzer errors for `player_surface.dart`.

## Task 3: Implement `PlayerSurface.build`

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/player_surface.dart`

- [ ] **Step 1: Add the build method**

Add this `build` method inside `_PlayerSurfaceState`:

```dart
@override
Widget build(BuildContext context) {
  final playerState = ref.watch(playerStateProvider);
  final castState = ref.watch(castServiceProvider);

  final videoWidth = playerState.videoWidth;
  final videoHeight = playerState.videoHeight;
  final isVideoReady =
      videoWidth != null && videoHeight != null && videoHeight > 0;
  final aspectRatio = isVideoReady ? videoWidth / videoHeight : 16 / 9;
  final fit = (aspectRatio - 1.0).abs() < 0.01
      ? widget.squareFit
      : widget.fit;
  final showLoadingIndicator = _updateAndReadLoadingState(playerState);

  return Stack(
    children: [
      Positioned.fill(
        child: Container(
          color: Colors.black,
          child: castState.isCasting
              ? Image.network(
                  excludeFromSemantics: true,
                  appendApiKey(
                    widget.scene.paths.screenshot ?? '',
                    ref.read(serverApiKeyProvider),
                  ),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.cast,
                      size: 64,
                      color: Colors.white24,
                    ),
                  ),
                )
              : TransformableVideoSurface(
                  fontSize: playerState.subtitleFontSize,
                  textAlign: _subtitleTextAlign(
                    playerState.subtitleTextAlignment,
                  ),
                  bottomRatio: playerState.subtitlePositionBottomRatio,
                  constraints: BoxConstraints.tight(
                    MediaQuery.sizeOf(context),
                  ),
                  controller: widget.controller,
                  aspectRatio: aspectRatio,
                  transformationNotifier: _transformationNotifier,
                  fit: fit,
                ),
        ),
      ),
      if (showLoadingIndicator && !castState.isCasting)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      if (castState.isCasting)
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cast_connected,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Casting to ${castState.activeSession?.device.name ?? 'Device'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: NativeVideoControls(
            controller: widget.controller,
            useDoubleTapSeek: playerState.useDoubleTapSeek,
            enableNativePip: playerState.enableNativePip,
            onFullScreenToggle: widget.onFullScreenToggle,
            scene: widget.scene,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onTransformationDelta: _onTransformationDelta,
          ),
        ),
      ),
    ],
  );
}
```

- [ ] **Step 2: Replace the constraints logic before use**

The first build method above uses `MediaQuery.sizeOf(context)` as a temporary compile target. Replace it immediately with a `LayoutBuilder` so the surface receives the actual parent constraints:

```dart
@override
Widget build(BuildContext context) {
  final playerState = ref.watch(playerStateProvider);
  final castState = ref.watch(castServiceProvider);

  final videoWidth = playerState.videoWidth;
  final videoHeight = playerState.videoHeight;
  final isVideoReady =
      videoWidth != null && videoHeight != null && videoHeight > 0;
  final aspectRatio = isVideoReady ? videoWidth / videoHeight : 16 / 9;
  final fit = (aspectRatio - 1.0).abs() < 0.01
      ? widget.squareFit
      : widget.fit;
  final showLoadingIndicator = _updateAndReadLoadingState(playerState);

  return LayoutBuilder(
    builder: (context, constraints) {
      return Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: castState.isCasting
                  ? Image.network(
                      excludeFromSemantics: true,
                      appendApiKey(
                        widget.scene.paths.screenshot ?? '',
                        ref.read(serverApiKeyProvider),
                      ),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(
                          Icons.cast,
                          size: 64,
                          color: Colors.white24,
                        ),
                      ),
                    )
                  : TransformableVideoSurface(
                      fontSize: playerState.subtitleFontSize,
                      textAlign: _subtitleTextAlign(
                        playerState.subtitleTextAlignment,
                      ),
                      bottomRatio: playerState.subtitlePositionBottomRatio,
                      constraints: constraints,
                      controller: widget.controller,
                      aspectRatio: aspectRatio,
                      transformationNotifier: _transformationNotifier,
                      fit: fit,
                    ),
            ),
          ),
          if (showLoadingIndicator && !castState.isCasting)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          if (castState.isCasting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cast_connected,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Casting to ${castState.activeSession?.device.name ?? 'Device'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: NativeVideoControls(
                controller: widget.controller,
                useDoubleTapSeek: playerState.useDoubleTapSeek,
                enableNativePip: playerState.enableNativePip,
                onFullScreenToggle: widget.onFullScreenToggle,
                scene: widget.scene,
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onTransformationDelta: _onTransformationDelta,
              ),
            ),
          ),
        ],
      );
    },
  );
}
```

- [ ] **Step 3: Format**

Run:

```bash
rtk dart format lib/features/scenes/presentation/widgets/player_surface.dart
```

Expected: formatter succeeds.

## Task 4: Use `PlayerSurface` in `SceneVideoPlayer`

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_video_player.dart`

- [ ] **Step 1: Remove imports made obsolete by extraction**

Remove these imports if they are no longer used:

```dart
import 'package:vector_math/vector_math_64.dart' show Vector3;
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/services/cast_service.dart';
import 'native_video_controls.dart';
import 'transformable_video_surface.dart';
```

Add:

```dart
import 'player_surface.dart';
```

- [ ] **Step 2: Remove duplicated surface state**

Remove these fields and methods from `_SceneVideoPlayerState`:

```dart
Timer? _bufferingDisplayTimer;
bool _showBufferingSpinner = false;
final ValueNotifier<Matrix4> _transformationNotifier = ValueNotifier(Matrix4.identity());
double _lastScale = 1.0;
double _lastRotation = 0.0;
```

Also remove `_onScaleStart`, `_onScaleUpdate`, and `_onTransformationDelta` from this class. Their full implementations now live in `PlayerSurface`.

Keep `_isStarting`.

- [ ] **Step 3: Update lifecycle cleanup**

Change `dispose()` so it no longer disposes surface-only state:

```dart
@override
void dispose() {
  // Note: We don't dispose the controller here as it is managed by the provider.
  super.dispose();
}
```

In `didUpdateWidget`, remove the buffering and transform reset lines. Keep `_isStarting = false` and the existing post-frame playback start.

- [ ] **Step 4: Replace the active playback stack**

Inside the active controller branch, keep `AspectRatio`, `Hero`, `LayoutBuilder`, max-height handling, and centering. Replace the inner `Stack` with:

```dart
return PlayerSurface(
  scene: widget.scene,
  controller: controller,
  onFullScreenToggle: _toggleFullScreen,
  fit: BoxFit.contain,
  squareFit: BoxFit.contain,
);
```

The active branch should still compute `aspectRatio` with `_effectiveAspectRatio(controller)` so inline layout behavior does not change.

- [ ] **Step 5: Format and run focused tests**

Run:

```bash
rtk dart format lib/features/scenes/presentation/widgets/scene_video_player.dart lib/features/scenes/presentation/widgets/player_surface.dart
rtk flutter test test/features/scenes/presentation/widgets/scene_video_player_test.dart test/features/scenes/video_player_ui_test.dart
```

Expected: both test files pass.

## Task 5: Use `PlayerSurface` in `GlobalFullscreenOverlay`

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart`

- [ ] **Step 1: Remove imports made obsolete by extraction**

Remove these imports if they are no longer used:

```dart
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:media_kit_video/media_kit_video.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/services/cast_service.dart';
import 'native_video_controls.dart';
import 'transformable_video_surface.dart';
```

Add:

```dart
import 'player_surface.dart';
```

Keep `media_kit_video` only if `VideoController` is still referenced by `_currentListenedController`.

- [ ] **Step 2: Remove duplicated surface state**

Remove these fields and methods from `_GlobalFullscreenOverlayState`:

```dart
Timer? _bufferingDisplayTimer;
bool _showBufferingSpinner = false;
final ValueNotifier<Matrix4> _transformationNotifier = ValueNotifier(Matrix4.identity());
double _lastScale = 1.0;
double _lastRotation = 0.0;
```

Also remove `_onScaleStart`, `_onScaleUpdate`, and `_onTransformationDelta` from this class. Their full implementations now live in `PlayerSurface`.

Keep `_currentListenedController`, `_subscriptions`, `_wasPlayingBeforeExit`, and fullscreen animation state.

- [ ] **Step 3: Update lifecycle cleanup**

Change `dispose()` so it no longer cancels the buffering timer or disposes transform state:

```dart
@override
void dispose() {
  _animationController.dispose();
  for (final sub in _subscriptions) {
    sub.cancel();
  }
  super.dispose();
}
```

- [ ] **Step 4: Replace fullscreen content stack**

In the `scene != null && controller != null` branch, replace the inner `LayoutBuilder` and duplicated `Stack` with:

```dart
content = PlayerSurface(
  scene: scene,
  controller: controller,
  onFullScreenToggle: _toggleFullScreen,
  fit: BoxFit.contain,
  squareFit: BoxFit.fill,
);
```

This preserves the existing fullscreen behavior where square videos use `BoxFit.fill`, while inline playback continues to use `BoxFit.contain`.

- [ ] **Step 5: Format and run focused tests**

Run:

```bash
rtk dart format lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart lib/features/scenes/presentation/widgets/player_surface.dart
rtk flutter test test/features/scenes/fullscreen_mode_test.dart
```

Expected: fullscreen visibility test passes.

## Task 6: Verify Imports, Analyzer, and Regression Suite

**Files:**
- Modify as needed:
  - `lib/features/scenes/presentation/widgets/player_surface.dart`
  - `lib/features/scenes/presentation/widgets/scene_video_player.dart`
  - `lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart`

- [ ] **Step 1: Search for unused old helper duplication**

Run:

```bash
rtk rg -n "_subtitleTextAlign|_showBufferingSpinner|_transformationNotifier|_onScaleStart|_onTransformationDelta" lib/features/scenes/presentation/widgets/scene_video_player.dart lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart lib/features/scenes/presentation/widgets/player_surface.dart
```

Expected:

- `player_surface.dart` contains the shared helpers.
- `scene_video_player.dart` and `global_fullscreen_overlay.dart` do not contain the duplicated surface helpers.

- [ ] **Step 2: Run analyzer on touched files**

Run:

```bash
rtk flutter analyze lib/features/scenes/presentation/widgets/player_surface.dart lib/features/scenes/presentation/widgets/scene_video_player.dart lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart
```

Expected: no analyzer errors.

- [ ] **Step 3: Run focused regression tests**

Run:

```bash
rtk flutter test test/features/scenes/presentation/widgets/scene_video_player_test.dart test/features/scenes/fullscreen_mode_test.dart test/features/scenes/video_player_ui_test.dart test/features/scenes/presentation/widgets/transformable_video_surface_test.dart test/features/scenes/presentation/widgets/native_video_controls_test.dart
```

Expected: all listed tests pass.

- [ ] **Step 4: Commit**

Run:

```bash
rtk git add lib/features/scenes/presentation/widgets/player_surface.dart lib/features/scenes/presentation/widgets/scene_video_player.dart lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart
rtk git commit -m "refactor: extract shared player surface"
```

Expected: commit succeeds with only the three touched widget files.

## Risk Notes

- `PlayerSurface` must not decide playback ownership. That stays in `SceneVideoPlayer` and `PlayerState`.
- `PlayerSurface` must not apply platform fullscreen side effects. That stays in `GlobalFullscreenOverlay` for this phase.
- Keep the inline/fullscreen square-video fit difference through the `squareFit` parameter.
- If media-kit controller construction makes direct widget tests hard, rely on existing parent widget tests for this phase and defer direct `PlayerSurface` tests until pure helpers are extracted.
