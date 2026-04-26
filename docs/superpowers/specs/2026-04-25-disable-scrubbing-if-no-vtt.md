# Spec: Disable Scene Card Scrubbing if VTT is Missing

## Problem
Currently, the `SceneCard` in the scene list page always listens for pan gestures even if the sprite image (VTT) is unavailable. While it doesn't show the preview, the active `GestureDetector` might still intercept gestures that should ideally pass through to parent widgets (like a scroll view) or simply remain inactive.

## Goal
Explicitly disable the pan gesture on the `SceneCard` if the VTT URL is empty, ensuring the UI remains responsive and gestures are handled predictably.

## Proposed Changes

### lib/features/scenes/presentation/widgets/scene_card.dart
- Update the `GestureDetector` in the `build` method (and sub-building methods if applicable).
- Conditionally set `onPanStart`, `onPanUpdate`, and `onPanEnd` to `null` if `vttUrl.isEmpty`.

## Success Criteria
- `SceneCard` does not intercept pan gestures when no VTT is available.
- Scrolling performance is unaffected or improved on cards without sprites.
- Scrubbing remains fully functional for cards with valid VTT URLs.
