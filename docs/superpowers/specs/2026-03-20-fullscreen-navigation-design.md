# Spec: Robust Full-Screen Navigation

Unified full-screen video navigation system using dedicated GoRouter routes to ensure consistent back-gesture behavior across standard and TikTok layouts.

## Goals
- Ensure system back gesture always exits full-screen mode correctly.
- Synchronize full-screen state with device orientation and system UI visibility.
- Provide a consistent user experience regardless of the starting view (Standard or TikTok).

## Architecture

### 1. Dedicated Routes
Update `lib/features/navigation/presentation/router.dart` to include:
- Standard Detail Fullscreen: `/scenes/scene/:id/fullscreen`
- TikTok Feed Fullscreen: `/scenes/fullscreen/:id`

### 2. Full-Screen Page Component
`lib/features/scenes/presentation/widgets/scene_video_player.dart`'s `FullscreenPlayerPage`:
- **State**: Manages `SystemChrome` (immersive mode, landscape orientation).
- **Cleanup**: In `dispose()`, restores Portrait orientation and edge-to-edge UI.
- **Back Interaction**: Relies on standard `Navigator.pop()` or system back gesture.

### 3. Integration Points
- **Standard View**: `_toggleFullScreen` in `SceneVideoPlayer` becomes `context.push('/scenes/scene/${scene.id}/fullscreen')`.
- **TikTok View**: `_toggleFullScreen` in `TiktokSceneItem` becomes `context.push('/scenes/fullscreen/${scene.id}')`.

## Validation Plan

### Automated UI Tests
Create `test/fullscreen_navigation_test.dart`:
- **Test 1**: Navigate from Scene Details to Fullscreen, then use Back. Verify return to Details.
- **Test 2**: Navigate from TikTok Feed to Fullscreen, then use Back. Verify return to TikTok Feed.
- **Test 3**: Verify `playerStateProvider.isFullScreen` is correctly synced during these transitions.
- **Test 4**: Verify MiniPlayer is hidden during full-screen navigation.
