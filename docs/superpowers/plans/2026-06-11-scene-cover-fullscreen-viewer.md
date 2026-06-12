# Scene Cover Fullscreen Viewer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Open scene covers in a non-immersive full-screen dialog with pinch zoom, double-tap zoom/reset, and an exit button.

**Architecture:** A dedicated `SceneCoverFullscreenViewer` owns transformation state and image gestures. `SceneInfoMediaSection` presents it only from cover mode using the root navigator, leaving preview playback and the underlying details sheet unchanged.

**Tech Stack:** Flutter, Riverpod, InteractiveViewer, flutter_test

---

### Task 1: Build The Fullscreen Viewer With Test-Driven Gestures

**Files:**
- Create: `lib/features/scenes/presentation/widgets/scene_cover_fullscreen_viewer.dart`
- Create: `test/features/scenes/presentation/widgets/scene_cover_fullscreen_viewer_test.dart`

- [ ] **Step 1: Write failing tests for zoom bounds, double tap, and exit**

Pump the viewer in a `MaterialApp` and assert an `InteractiveViewer` has
`minScale == 1`, `maxScale == 4`, and pan/scale enabled. Double-tap the keyed
image surface and assert the exposed `TransformationController.value`
represents scale `2.5`; double-tap again and assert it equals
`Matrix4.identity()`. Tap the localized exit button and assert the route pops.

- [ ] **Step 2: Run the focused test and verify RED**

Run:

```bash
rtk proxy env HOME=/tmp flutter test test/features/scenes/presentation/widgets/scene_cover_fullscreen_viewer_test.dart
```

Expected: FAIL because `SceneCoverFullscreenViewer` does not exist.

- [ ] **Step 3: Implement the minimal fullscreen viewer**

Create a `ConsumerStatefulWidget` accepting `imageUrl` and an optional
`TransformationController` for tests. Use a black `Scaffold`, a `Stack`,
`InteractiveViewer`, a double-tap `GestureDetector`, and a top-right safe-area
`IconButton` using `Icons.fullscreen_exit_rounded`.

Capture `onDoubleTapDown.localPosition`. For zoom-in, assign:

```dart
Matrix4.identity()
  ..translate(
    -tap.dx * (2.5 - 1),
    -tap.dy * (2.5 - 1),
  )
  ..scale(2.5);
```

For reset, assign `Matrix4.identity()`.

- [ ] **Step 4: Run the focused viewer test and verify GREEN**

Run the focused test. Expected: all viewer tests PASS.

### Task 2: Open The Viewer From Cover Mode

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_info_media_section.dart`
- Modify: `test/features/scenes/presentation/widgets/scene_info_media_section_test.dart`

- [ ] **Step 1: Write failing integration tests**

Pump the media section with real cover rendering replaced by a keyed test
surface. Tap `scene_info_media_cover_tap_target` and assert
`scene_cover_fullscreen_viewer` appears. Tap its exit button and assert the
viewer disappears while `scene_info_media_section` remains.

Switch to Preview, tap `scene_info_media_preview`, and assert the fullscreen
viewer is not present.

- [ ] **Step 2: Run the media-section tests and verify RED**

Run:

```bash
rtk proxy env HOME=/tmp flutter test test/features/scenes/presentation/widgets/scene_info_media_section_test.dart
```

Expected: FAIL because cover mode has no fullscreen tap target or dialog.

- [ ] **Step 3: Add cover dialog presentation**

Wrap the cover subtree in `Material` and `InkWell` with the key
`scene_info_media_cover_tap_target`. Present:

```dart
showGeneralDialog<void>(
  context: context,
  useRootNavigator: true,
  barrierDismissible: false,
  barrierColor: Colors.black,
  transitionDuration: const Duration(milliseconds: 180),
  pageBuilder: (_, __, ___) =>
      SceneCoverFullscreenViewer(imageUrl: coverUrl),
);
```

Do not wrap preview mode in this tap target.

- [ ] **Step 4: Run media-section tests and verify GREEN**

Run the focused media-section tests. Expected: all tests PASS.

### Task 3: Format And Verify

**Files:**
- Verify all viewer and media-section files

- [ ] **Step 1: Format changed Dart files**

Run:

```bash
rtk dart format lib/features/scenes/presentation/widgets/scene_cover_fullscreen_viewer.dart lib/features/scenes/presentation/widgets/scene_info_media_section.dart test/features/scenes/presentation/widgets/scene_cover_fullscreen_viewer_test.dart test/features/scenes/presentation/widgets/scene_info_media_section_test.dart
```

- [ ] **Step 2: Run focused widget suites**

Run:

```bash
rtk proxy env HOME=/tmp flutter test test/features/scenes/presentation/widgets/scene_cover_fullscreen_viewer_test.dart test/features/scenes/presentation/widgets/scene_info_media_section_test.dart test/features/scenes/video_player_ui_test.dart
```

Expected: all focused tests PASS.

- [ ] **Step 3: Run focused analysis**

Run:

```bash
rtk proxy env HOME=/tmp flutter analyze lib/features/scenes/presentation/widgets/scene_cover_fullscreen_viewer.dart lib/features/scenes/presentation/widgets/scene_info_media_section.dart test/features/scenes/presentation/widgets/scene_cover_fullscreen_viewer_test.dart test/features/scenes/presentation/widgets/scene_info_media_section_test.dart
```

Expected: no analyzer issues.

- [ ] **Step 4: Review the final diff**

Run `rtk git diff --check` and confirm the viewer does not alter system UI,
cover-only taps open it, preview taps do not, zoom bounds are `1x` to `4x`,
double-tap toggles `1x`/`2.5x`, and exit returns to the existing sheet.
