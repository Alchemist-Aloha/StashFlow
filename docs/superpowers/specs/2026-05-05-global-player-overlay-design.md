# Design: Global Persistent Player Overlay

This design replaces the route-based fullscreen player with a persistent global overlay managed at the root of the application. This ensures that the player's lifecycle is decoupled from navigation, providing a more robust experience during "Play Next" transitions and cross-page navigation.

## Goals

- **Robustness:** Eliminate "controller not found" errors caused by route-based state handoffs.
- **Continuity:** Allow seamless playback while navigating the background app.
- **Predictable Navigation:** Ensure exiting fullscreen always lands the user on the correct scene details page.
- **Smooth Transitions:** Use a persistent widget to avoid flickering during `Hero` transitions or page swaps.

## Architecture

### 1. Root-Level Integration (`ShellPage`)

The `ShellPage` will be refactored to include a `Stack` at its root.

```dart
Stack(
  children: [
    // Layer 0: Main Navigation (GoRouter Shell)
    navigationShell, 
    
    // Layer 1: Mini Player (Visible when not in fullscreen and scene active)
    if (!isFullScreen && hasActiveScene) MiniPlayer(),

    // Layer 2: Global Fullscreen Overlay
    GlobalFullscreenOverlay(),
  ],
)
```

### 2. GlobalFullscreenOverlay Component

This new component will be a stateful widget that reacts to `playerStateProvider.isFullScreen`.

- **Visibility:** Uses `AnimatedVisibility` or a `Stack` entry with a `SlideTransition` to animate in/out.
- **State Source:** Consumes `playerStateProvider` for the `activeScene`, `player`, and `videoController`.
- **Orientation Control:** Manages `SystemChrome.setPreferredOrientations` locally based on its visibility state.
- **Back Gesture Handling:** Uses `PopScope` to intercept system back events when visible, triggering the exit flow instead of popping the background stack.

### 3. Navigation Synchronization

To maintain a logical history while allowing independent playback in fullscreen:

- **Playback in Fullscreen:** When "Next" is triggered, `PlayerState` updates the `activeScene` and `player` state. The background URL remains unchanged.
- **Exit Flow:**
    1. User triggers exit (Back button or UI toggle).
    2. The system compares the current URL with the `activeScene.id`.
    3. If they don't match, `context.go('/scenes/scene/${activeScene.id}')` is called to sync the background "silently" before the overlay disappears.
    4. `playerStateProvider.isFullScreen` is set to `false`, triggering the exit animation.

## UI/UX

- **Entry Animation:** Slide up from bottom or scale-up from the mini-player (if active).
- **Exit Animation:** Slide down to bottom or fade out.
- **Controls:** Reuses `NativeVideoControls` and `TransformableVideoSurface`.

## Success Criteria

1.  Entering fullscreen from any page (Details, TikTok, Search) works reliably.
2.  Playing the "Next" video while in fullscreen works without exiting or flickering.
3.  Exiting fullscreen from a "Next" video lands the user on the Details page for that *new* video.
4.  The system back gesture correctly closes the fullscreen overlay.
