# Design Spec: UI Enhancements and DLNA Casting

**Date:** 2026-04-28
**Topic:** Improving StashFlow's UI polish and feature set by porting high-impact patterns from PiliPlus.

## 1. Overview
The goal is to elevate StashFlow's user experience in three key areas:
1.  **Perceived Performance:** Replace generic loading indicators with shimmering skeleton loaders that mirror the actual content layout.
2.  **Video Interaction:** Add modern video gestures (long-press speed-up and vertical side-swipes for volume/brightness) with polished visual feedback.
3.  **Connectivity:** Implement DLNA/UPnP casting to allow users to play content on Smart TVs and media players.

## 2. Architecture & Components

### 2.1 Skeleton Loading System
A unified shimmering system to reduce perceived wait times.

- **`Skeleton` Widget:** A core utility widget using `ShaderMask` and `AnimationController` to create a sweeping gradient effect over its child.
- **`SceneCardSkeleton`:** A dedicated skeleton widget that perfectly mirrors the structure of `SceneCard` (Thumbnail + Metadata + Icons). It will support both Grid and List layouts.
- **Integration:** `ListPageScaffold` will be updated to render a placeholder list/grid of skeletons when `provider.isLoading` is true, ensuring a seamless transition to the actual data.

### 2.2 Advanced Video Gestures
Enhanced control for the `NativeVideoControls` widget.

- **Long-Press Speed-Up:**
    - Initial `onLongPressStart`: Sets playback speed to 2.0x.
    - `onLongPressMoveUpdate`: If dragging upwards (negative `dy`), linearly increases speed from 2.0x to 10.0x.
    - `onLongPressEnd`: Resets speed to the original value (usually 1.0x).
- **Vertical Side-Swipes:**
    - Split the screen into two vertical zones.
    - **Left Zone:** Vertical drag adjusts screen brightness (via `screen_brightness` package).
    - **Right Zone:** Vertical drag adjusts volume (via `playerStateProvider` or native volume APIs).
- **Gesture Feedback Overlay:**
    - A centralized overlay widget in `NativeVideoControls`.
    - Uses `AnimatedScale` and `AnimatedOpacity` to show a large, semi-transparent icon and percentage/speed label in the center of the screen when gestures are active.

### 2.3 DLNA Casting
Native discovery and playback on external devices.

- **`CastService` (Riverpod):** Manages device discovery and life-cycle using the `dlna_dart` package.
- **`CastSelectionSheet`:** A Material bottom sheet triggered from the video player that lists discovered DLNA devices.
- **Playback Control:** When a device is selected, the local player pauses, and the video URL (with auth headers) is sent to the target device via UPnP `SetAVTransportURI` and `Play` commands.

## 3. Data Flow & State Management

- **Gestures:** Local state within `NativeVideoControls` will handle the real-time feedback (speed/volume levels). Permanent changes (volume) will be synced back to the global `DesktopSettings` or `PlayerState`.
- **Casting:** `CastService` will maintain an `AsyncValue<List<DLNADevice>>` of discovered devices. Selection state will be managed globally to allow the mini-player to reflect that the content is being cast.

## 4. Success Criteria
- [ ] `ScenesPage` displays a shimmering grid/list during initial load.
- [ ] Long-pressing a video in `NativeVideoControls` speeds it up to 2x+, with a visual "2.0x" indicator.
- [ ] Vertical swiping on the left/right sides of the video player adjusts brightness/volume with smooth visual feedback.
- [ ] "Cast" button appears in video controls and successfully discovers local DLNA devices.
- [ ] Video playback can be started on a DLNA-compatible device.

## 5. Testing Strategy
- **Unit Tests:** Verify `Skeleton` animation logic and `CastService` device discovery filtering.
- **Widget Tests:** Ensure `SceneCardSkeleton` renders correctly in various layout modes.
- **Manual Verification:** Test gesture sensitivity and visual feedback across different screen sizes and orientations. Validate DLNA casting with real hardware.
