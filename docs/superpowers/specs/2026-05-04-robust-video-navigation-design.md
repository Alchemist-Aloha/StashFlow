# Spec: Robust Video State Control & Navigation

**Date:** 2026-05-04
**Topic:** Video Playback Reliability, Fullscreen Navigation, and Auto-play Transitions.

## 1. Problem Statement
The current video playback system suffers from "View Desync" and "Ownership Conflicts":
1.  **Navigation Desync:** When auto-playing scenes in fullscreen, the underlying `SceneDetailsPage` remains on the previous scene. Exiting fullscreen lands the user on stale data.
2.  **Ownership Conflict:** Multiple widgets (`SceneVideoPlayer`, `FullscreenPlayerPage`, `SceneDetailsPage`) independently react to `playerStateProvider`, leading to redundant playback triggers and race conditions.
3.  **Auto-play Regression:** Current fullscreen "auto-exit" fixes break the immersive experience by forcing a pop when the video ends, which then triggers a re-initialization of the player on the details page.

## 2. Goals
*   **Robust State Control:** A single source of truth for "who" currently owns the video player.
*   **Coordinated Navigation:** Navigation and playback updates happen atomically.
*   **Seamless Fullscreen Auto-play:** Transition between scenes in fullscreen without dropping to the details page.
*   **Healed History Stack:** Ensure the "Back" button always leads to the *current* scene's details page, while preserving linear history.

## 3. Proposed Architecture: The Playback Coordinator

### 3.1 Global State Enhancements
We will enhance `GlobalPlayerState` to include UI context:

```dart
enum PlayerViewMode { 
  inline,      // Played within SceneDetailsPage
  fullscreen,  // Played within FullscreenPlayerPage
  tiktok       // Played within TikTokView
}

class GlobalPlayerState {
  final Scene? activeScene;
  final PlayerViewMode viewMode;
  final bool isTransitioning; // Flag to ignore redundant triggers during navigation
  // ... existing fields
}
```

### 3.2 View Ownership Logic
Widgets must respect the `viewMode` before interacting with the shared `Player`:

*   **`SceneVideoPlayer` (Inline):** Only attempts to `_startPlaybackIfNeeded` if `viewMode == inline`.
*   **`FullscreenPlayerPage`:** Only displays if `viewMode == fullscreen`.
*   **`TikTokView`:** Only displays if `viewMode == tiktok`.

### 3.3 Coordinated Navigation
The `PlayerState` notifier will act as the **Coordinator**. It will manage navigation via a registered callback or by emitting `NavigationIntent` objects.

#### Scenario: Fullscreen Auto-play (Scene A -> Scene B)
1.  Video A ends. `PlayerState._handleVideoFinished` is called.
2.  Coordinator determines `playEndBehavior == next` and `viewMode == fullscreen`.
3.  Coordinator sets `isTransitioning = true`.
4.  Coordinator resolves Scene B and updates `activeScene`.
5.  **Stack Reconstruction:** Coordinator triggers a navigation sequence:
    *   `context.pushReplacement('/scenes/scene/B')` (Replaces `Fullscreen A` with `Details B`).
    *   `context.push('/scenes/fullscreen/B')` (Pushes `Fullscreen B` on top of `Details B`).
    *   *Note:* This ensures the stack is `Details A -> Details B -> Fullscreen B`.
6.  `isTransitioning` is set to `false`.

#### Scenario: Exiting Fullscreen B
1.  User hits "Back".
2.  `FullscreenPlayerPage` calls `coordinator.exitFullscreen()`.
3.  Coordinator sets `viewMode = inline`.
4.  `Navigator.pop(context)` returns the user to `Details B`, which is already in the stack and initialized.

## 4. Implementation Details

### 4.1 `PlayerState` Notifier Updates
*   Add `viewMode` and `isTransitioning` to the state.
*   Update `playNext()` and `playScene()` to manage these flags.
*   Implement `setViewMode(PlayerViewMode mode)`.

### 4.2 `SceneVideoPlayer` Updates
*   Refactor `_startPlaybackIfNeeded` to check `playerState.viewMode`.
*   Remove the `ref.listen` block in `SceneDetailsPage` that handles navigation (this is now the Coordinator's job).

### 4.3 `FullscreenPlayerPage` Updates
*   Use `PopScope` to ensure `setViewMode(inline)` is called on every exit path (gesture, button, system back).
*   Remove auto-exit logic that triggers on scene change; the Coordinator will handle replacement instead.

## 5. Testing & Validation
1.  **Linear History Test:** Auto-play 3 scenes in fullscreen, exit, and verify that "Back" goes through each scene's details page.
2.  **Ownership Test:** Verify that while in fullscreen, the background `SceneDetailsPage` does not log playback activity or attempt to pause/play the video.
3.  **Flicker Test:** Ensure the `pushReplacement` + `push` sequence doesn't cause visible UI flashing on different platforms (Web, Android, Desktop).

## 6. Constraints & Risks
*   **Hero Transitions:** The double-navigation (`pushReplacement` + `push`) might interfere with Hero animations if not timed correctly. We may need to use `NoTransitionPage` for the intermediate `Details B` push.
*   **GoRouter Complexity:** `pushReplacement` behaves differently in nested shells. We must ensure the `coordinator` is aware of the current router context.
