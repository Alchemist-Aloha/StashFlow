# Spec: Scene Details Video Layout Fix

This document outlines the design for fixing the vertical video cropping issue in the scene details page. Currently, vertical videos expand to the full width of the screen, resulting in their height exceeding the viewport or being cropped.

## 1. Problem Statement
In the `SceneDetailsPage`, the video player is implemented using an `AspectRatio` widget that takes up the full width of its parent. For vertical (portrait) videos, this results in a height that often exceeds the available screen space, leading to:
- The top/bottom of the video being cut off on desktop/mobile.
- User having to scroll to see the metadata or the bottom of the video.
- Inconsistent visual experience across different aspect ratios.

## 2. Goals
- **Full Visibility:** Ensure the entire video (top to bottom) is visible within the viewport without scrolling.
- **Aspect Ratio Integrity:** Maintain the original aspect ratio of the video.
- **Responsiveness:** Work correctly on mobile (portrait/landscape) and desktop (resizable windows).
- **No Performance Degradation:** Avoid complex calculations or expensive layout passes.

## 3. Proposed Solution: Calculated Safe Height (Approach 2)
We will constrain the video player's maximum height based on the available visible space in the viewport.

### 3.1. `SceneDetailsPage` Modifications
Calculate the "Safe Max Height" during the build process:
- `Total Viewport Height` (from `MediaQuery.of(context).size.height`)
- Subtract `Status Bar Height` (`MediaQuery.of(context).padding.top`)
- Subtract `AppBar Height` (`AppBar().preferredSize.height`)
- Subtract a small safety margin (e.g., 20 pixels) to ensure the video doesn't touch the bottom edge of the viewport.

Wrap the `SceneVideoPlayer` in:
1. `Center`: To ensure narrow vertical videos are centered horizontally.
2. `ConstrainedBox`: To apply the `maxHeight` constraint.

### 3.2. `SceneVideoPlayer` Considerations
The `SceneVideoPlayer` already handles aspect ratio via the `AspectRatio` widget. When height-constrained, the `AspectRatio` widget will automatically reduce its width to maintain the ratio.

## 4. Technical Details

### 4.1. Safe Height Calculation
```dart
final mediaQuery = MediaQuery.of(context);
final topPadding = mediaQuery.padding.top;
final appBarHeight = Scaffold.of(context).hasAppBar 
    ? AppBar().preferredSize.height 
    : 0.0;
final safeMaxHeight = mediaQuery.size.height - topPadding - appBarHeight - 20;
```

### 4.2. UI Structure (Mobile & Desktop Left Column)
```dart
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxHeight: safeMaxHeight),
    child: SceneVideoPlayer(scene: scene),
  ),
)
```

## 5. Testing Plan
- **Manual Verification:**
  - Verify 16:9, 1:1, and 9:16 videos on mobile (Portrait and Landscape).
  - Verify window resizing on Desktop.
  - Ensure metadata is still reachable and the page remains scrollable.
- **Automated Tests:**
  - Update or add a widget test to verify that `SceneVideoPlayer` dimensions are constrained within the safe height limits.

## 6. Performance Impact
Negligible. `MediaQuery` and `ConstrainedBox` are efficient, native Flutter widgets designed for this purpose. Calculation happens during the standard build phase.
