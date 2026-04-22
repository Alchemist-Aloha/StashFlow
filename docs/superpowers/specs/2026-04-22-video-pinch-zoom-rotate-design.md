# Design Spec: Video Player Pinch-to-Zoom and Free Rotation

## 1. Overview
Add the ability for users to pinch to zoom and freely rotate the video surface in both the inline (scene details) and fullscreen video players. This improves accessibility and allows users to inspect details or adjust for orientation in non-standard video files.

## 2. Requirements
- **Pinch-to-Zoom**: Smoothly scale the video content using a two-finger pinch gesture.
- **Free Rotation**: Allow continuous rotation of the video content using a two-finger twist gesture.
- **Panning**: Allow moving the zoomed/rotated video surface within its container.
- **Gesture Isolation**: Transformation gestures must only trigger when 2 fingers are detected to avoid conflicts with one-finger seek/scrub gestures.
- **Reset State**: Transformations must reset to the default (identity) state when:
    - Navigating between scenes.
    - Entering or exiting fullscreen mode.
- **UI Integrity**: Subtitles and playback controls must remain fixed and should NOT be affected by the video transformation.

## 3. Architecture

### 3.1 `TransformableVideoSurface` Widget
A new stateful widget will be created to manage the transformation state and gesture handling.

**Props:**
- `VideoPlayerController controller`: The active controller.
- `double aspectRatio`: The intended aspect ratio of the video surface.

**State:**
- `Matrix4 _transformationMatrix`: Stores the combined scale, rotation, and translation.
- `Offset _lastFocalPoint`: Tracks the center of the gesture for smooth panning.
- `double _startScale`: Scale value at the start of the gesture.
- `double _startRotation`: Rotation value at the start of the gesture.

### 3.2 Integration into `SceneVideoPlayer`
The `SceneVideoPlayer` widget (used for both inline and fullscreen) currently renders the `VideoPlayer` directly inside a `Stack`.

**Current Structure:**
```dart
Stack(
  children: [
    VideoPlayer(controller), // To be replaced
    SceneSubtitleOverlay(...),
    NativeVideoControls(...),
  ]
)
```

**New Structure:**
```dart
Stack(
  children: [
    TransformableVideoSurface(
      controller: controller,
      aspectRatio: controller.value.aspectRatio,
    ),
    SceneSubtitleOverlay(...),
    NativeVideoControls(...),
  ]
)
```

## 4. Gesture Handling Logic

The `GestureDetector` inside `TransformableVideoSurface` will handle the following:

### 4.1 `onScaleStart`
- Store initial `_transformationMatrix`.
- Record `_lastFocalPoint`.
- Initialize `_startScale` and `_startRotation`.

### 4.2 `onScaleUpdate`
- Check `details.pointerCount`.
- If `pointerCount == 2`:
    - Calculate `scaleDelta` and `rotationDelta`.
    - Calculate `translationDelta` from focal point movement.
    - Update `_transformationMatrix` using `Matrix4` operations (scaling and rotating around the focal point).
    - Call `setState()`.

### 4.3 `onScaleEnd`
- Finalize the transformation.
- No inertia/decay will be implemented in the first iteration to keep the logic simple and predictable.

## 5. Reset Behavior
The `TransformableVideoSurface` will be keyed by the `sceneId` or explicitly reset in `initState`. Since entering/exiting fullscreen uses a `Hero` transition and different page instances, the state will naturally reset as the new widget instance initializes with `Matrix4.identity()`.

## 6. Testing Strategy
- **Manual Verification**:
    - Verify one-finger horizontal drag still performs seeking.
    - Verify two-finger pinch scales the video.
    - Verify two-finger twist rotates the video.
    - Verify controls and subtitles stay fixed during transformation.
    - Verify exiting fullscreen resets the zoom/rotation.
- **Automated Tests**:
    - Add a widget test to ensure `TransformableVideoSurface` applies the correct `Matrix4` updates when receiving simulated scale gestures.
