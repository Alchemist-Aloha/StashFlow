# Robust Full-Screen Navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a dedicated navigation route for full-screen video playback to ensure robust back-gesture handling and device orientation management across all view modes.

**Architecture:** We will add `/fullscreen/:id` routes to `GoRouter`, refactor `FullscreenPlayerPage` to be a standalone routable component that manages system UI cleanup in `dispose()`, and update both Standard and TikTok views to use `context.push()` for entering full-screen mode.

**Tech Stack:** Flutter, GoRouter, Riverpod, SystemChrome, WakelockPlus.

---

### Task 1: Router Updates

**Files:**
- Modify: `lib/features/navigation/presentation/router.dart`

- [ ] **Step 1: Add dedicated full-screen routes**
Add the following routes to the `GoRouter` configuration:
- Under `/scenes` branch: `GoRoute(path: 'scene/:id/fullscreen', ...)`
- As a top-level or branch route: `GoRoute(path: '/scenes/fullscreen/:id', ...)` (or similar depending on nesting).

- [ ] **Step 2: Commit**
```bash
git add lib/features/navigation/presentation/router.dart
git commit -m "chore: add dedicated fullscreen routes to GoRouter"
```

### Task 2: Standardize FullscreenPlayerPage

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_video_player.dart`

- [ ] **Step 1: Refactor FullscreenPlayerPage to use passed controller or resolve it**
Ensure `FullscreenPlayerPage` can retrieve the `VideoPlayerController` from `playerStateProvider` safely.

- [ ] **Step 2: Update dispose logic for total cleanup**
Ensure `dispose()` calls:
```dart
SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, ...]);
ref.read(playerStateProvider.notifier).setFullScreen(false);
```

- [ ] **Step 3: Commit**
```bash
git add lib/features/scenes/presentation/widgets/scene_video_player.dart
git commit -m "feat: robust cleanup in FullscreenPlayerPage dispose"
```

### Task 3: Update View Interactions

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_video_player.dart` (Standard)
- Modify: `lib/features/scenes/presentation/widgets/tiktok_scenes_view.dart` (TikTok)

- [ ] **Step 1: Update Standard View full-screen toggle**
Change `_toggleFullScreen` to use `context.push('/scenes/scene/${widget.scene.id}/fullscreen')`.

- [ ] **Step 2: Update TikTok View full-screen toggle**
Change `_toggleFullScreen` to use `context.push('/scenes/fullscreen/${widget.scene.id}')`.

- [ ] **Step 3: Commit**
```bash
git add lib/features/scenes/presentation/widgets/scene_video_player.dart lib/features/scenes/presentation/widgets/tiktok_scenes_view.dart
git commit -m "feat: use context.push for fullscreen navigation in both views"
```

### Task 4: Extensive UI Navigation Tests

**Files:**
- Create: `test/fullscreen_navigation_test.dart`

- [ ] **Step 1: Write tests for Standard -> Fullscreen -> Back**
Verify that swiping back from fullscreen returns to the correct Scene Details page.

- [ ] **Step 2: Write tests for TikTok -> Fullscreen -> Back**
Verify that swiping back from fullscreen returns to the vertical TikTok feed.

- [ ] **Step 3: Verify system state synchronization**
Assert that `playerStateProvider.isFullScreen` is true in fullscreen and false after back.

- [ ] **Step 4: Run tests**
Run: `flutter test test/fullscreen_navigation_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**
```bash
git add test/fullscreen_navigation_test.dart
git commit -m "test: extensive fullscreen navigation and back gesture tests"
```
