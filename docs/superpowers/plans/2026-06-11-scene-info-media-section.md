# Scene Info Media Section Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a cover/preview media section to the scene information bottom sheet with availability-aware toggling and an isolated paused media_kit preview player.

**Architecture:** A focused `SceneInfoMediaSection` widget owns mode selection, URL/auth resolution, and a short-lived preview player. `SceneInfoPage` embeds it below the header, while tests inject a controllable preview surface/player boundary to avoid native media initialization.

**Tech Stack:** Flutter, Riverpod, media_kit, media_kit_video, flutter_test

---

### Task 1: Specify Media Availability and Initial Display

**Files:**
- Create: `lib/features/scenes/presentation/widgets/scene_info_media_section.dart`
- Create: `test/features/scenes/presentation/widgets/scene_info_media_section_test.dart`

- [ ] **Step 1: Write failing widget tests for all availability combinations**

Create test scenes with both assets, cover only, preview only, and neither.
Assert:

```dart
expect(find.byKey(const Key('scene_info_media_section')), findsOneWidget);
expect(find.byKey(const Key('scene_info_media_toggle')), findsOneWidget);
expect(find.byKey(const Key('scene_info_media_cover')), findsOneWidget);
expect(find.byKey(const Key('scene_info_media_preview')), findsNothing);
```

For cover-only and preview-only scenes, assert that the appropriate surface is
present and the toggle is absent. For a scene with neither asset, assert that
the section key is absent.

- [ ] **Step 2: Run the focused test and verify RED**

Run:

```bash
rtk proxy 'env HOME=/tmp flutter test test/features/scenes/presentation/widgets/scene_info_media_section_test.dart'
```

Expected: FAIL because `SceneInfoMediaSection` does not exist.

- [ ] **Step 3: Implement availability rendering and Cover/Preview selection**

Add `SceneInfoMediaSection` as a `ConsumerStatefulWidget`. Normalize the cover
and preview strings, return `SizedBox.shrink()` when both are empty, default to
cover when available, and use a two-segment `SegmentedButton` only when both
assets exist.

Render the cover with:

```dart
StashImage(
  key: const Key('scene_info_media_cover'),
  imageUrl: coverUrl,
  width: double.infinity,
  height: double.infinity,
  fit: BoxFit.contain,
)
```

Use a keyed placeholder preview surface initially so the availability tests do
not require native media initialization.

- [ ] **Step 4: Run the focused test and verify GREEN**

Run the same focused Flutter test command. Expected: all availability and
default-mode tests PASS.

### Task 2: Add the Isolated Paused Preview Player

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_info_media_section.dart`
- Modify: `test/features/scenes/presentation/widgets/scene_info_media_section_test.dart`

- [ ] **Step 1: Write failing tests for preview initialization and mode changes**

Inject a preview-player factory that records the requested autoplay state and
disposal. For both-assets mode, tap the Preview segment and assert the preview
surface is shown with autoplay enabled. Tap Cover and assert the cover returns
and the preview player is disposed. For preview-only mode, assert
initialization occurs immediately with autoplay enabled.

- [ ] **Step 2: Run the focused test and verify RED**

Run the focused widget test. Expected: FAIL because preview lifecycle injection
and paused opening are not implemented.

- [ ] **Step 3: Implement preview player lifecycle**

Add a small injectable preview session abstraction whose production
implementation creates `Player` and `VideoController`. Resolve
`scene.paths.preview` with `resolveGraphqlMediaUrl`, apply
`mediaPlaybackHeadersProvider`, and apply `applyWebMediaAuthFallback` on web.
Open:

```dart
await player.open(
  Media(effectivePreviewUrl, httpHeaders: effectiveHeaders),
  play: false,
);
```

Wrap `Video(controller: controller)` in `MaterialVideoControlsTheme` and
`MaterialDesktopVideoControlsTheme`. Dispose when switching to Cover, on widget
disposal, or when the scene/preview URL changes, and show loading/error
overlays.

- [ ] **Step 4: Run the focused test and verify GREEN**

Run the focused widget test. Expected: all media-section tests PASS.

### Task 3: Place the Section in SceneInfoPage

**Files:**
- Modify: `lib/features/scenes/presentation/pages/scene_info_page.dart`
- Modify: `test/features/scenes/video_player_ui_test.dart`

- [ ] **Step 1: Write a failing integration widget test**

Update the existing `SceneCard three-dot opens scene info page` test scene to
include a screenshot and preview. After opening the sheet, assert that
`scene_info_media_section` appears before the first metadata chip by comparing
their vertical positions.

- [ ] **Step 2: Run the integration test and verify RED**

Run:

```bash
rtk proxy 'env HOME=/tmp flutter test test/features/scenes/video_player_ui_test.dart --plain-name "SceneCard three-dot opens scene info page"'
```

Expected: FAIL because `SceneInfoPage` does not include the media section.

- [ ] **Step 3: Embed the media section**

Import `scene_info_media_section.dart` and add:

```dart
SceneInfoMediaSection(scene: scene),
const SizedBox(height: 12),
```

directly below the header, conditionally preserving spacing when no media is
available through a public availability helper or a boolean computed from the
scene paths.

- [ ] **Step 4: Run the integration test and verify GREEN**

Run the same named test. Expected: PASS.

### Task 4: Format and Verify the Feature

**Files:**
- Verify all modified Dart files

- [ ] **Step 1: Format the changed Dart files**

Run:

```bash
rtk dart format lib/features/scenes/presentation/widgets/scene_info_media_section.dart lib/features/scenes/presentation/pages/scene_info_page.dart test/features/scenes/presentation/widgets/scene_info_media_section_test.dart test/features/scenes/video_player_ui_test.dart
```

- [ ] **Step 2: Run focused tests**

Run:

```bash
rtk proxy 'env HOME=/tmp flutter test test/features/scenes/presentation/widgets/scene_info_media_section_test.dart test/features/scenes/video_player_ui_test.dart'
```

Expected: all focused tests PASS.

- [ ] **Step 3: Run focused static analysis**

Run:

```bash
rtk proxy 'env HOME=/tmp flutter analyze lib/features/scenes/presentation/widgets/scene_info_media_section.dart lib/features/scenes/presentation/pages/scene_info_page.dart test/features/scenes/presentation/widgets/scene_info_media_section_test.dart test/features/scenes/video_player_ui_test.dart'
```

Expected: no new analyzer issues.

- [ ] **Step 4: Review the final diff**

Run:

```bash
rtk git diff --check
rtk git diff -- lib/features/scenes/presentation/widgets/scene_info_media_section.dart lib/features/scenes/presentation/pages/scene_info_page.dart test/features/scenes/presentation/widgets/scene_info_media_section_test.dart test/features/scenes/video_player_ui_test.dart
```

Confirm every availability state, paused initialization, toggle behavior,
player disposal, and sheet placement matches the approved design.
