# Scene Details Video Layout Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Constrain the video player height in the scene details page to ensure vertical videos fit within the viewport without cropping.

**Architecture:** Modify `SceneDetailsPage` to calculate a maximum "safe" height (viewport minus system bars and AppBar) and wrap the `SceneVideoPlayer` in a `ConstrainedBox` and `Center`.

**Tech Stack:** Flutter (Riverpod, MediaQuery)

---

### Task 1: Research and Verify Current Behavior

**Files:**
- Modify: `lib/features/scenes/presentation/pages/scene_details_page.dart`

- [ ] **Step 1: Locate the video player implementation in `SceneDetailsPage`**
Identify the two places where `SceneVideoPlayer(scene: scene)` is used (Desktop/Tablet view and Mobile view).

- [ ] **Step 2: Commit initial state (No changes yet)**
```bash
git add lib/features/scenes/presentation/pages/scene_details_page.dart
git commit -m "chore: baseline for video layout fix"
```

### Task 2: Calculate Safe Max Height in `SceneDetailsPage`

**Files:**
- Modify: `lib/features/scenes/presentation/pages/scene_details_page.dart`

- [ ] **Step 1: Implement safe height calculation logic**
In the `build` method of `_SceneDetailsPageState`, calculate the available height.

```dart
// Inside build()
final mediaQuery = MediaQuery.of(context);
final topPadding = mediaQuery.padding.top;
// We check if Scaffold has an AppBar. In our case it does.
final appBarHeight = AppBar().preferredSize.height;
final safeMaxHeight = mediaQuery.size.height - topPadding - appBarHeight - 20;
```

- [ ] **Step 2: Apply constraints to the Desktop/Tablet layout**
Wrap the `SceneVideoPlayer` in the `Row` -> `Expanded` (flex 618) section.

```dart
// lib/features/scenes/presentation/pages/scene_details_page.dart

// Find: SceneVideoPlayer(scene: scene),
// Replace with:
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxHeight: safeMaxHeight),
    child: SceneVideoPlayer(scene: scene),
  ),
),
```

- [ ] **Step 3: Apply constraints to the Mobile layout**
Wrap the `SceneVideoPlayer` in the default `Column` section.

```dart
// lib/features/scenes/presentation/pages/scene_details_page.dart

// Find: SceneVideoPlayer(scene: scene),
// Replace with:
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxHeight: safeMaxHeight),
    child: SceneVideoPlayer(scene: scene),
  ),
),
```

- [ ] **Step 4: Verify syntax and commit**
```bash
git add lib/features/scenes/presentation/pages/scene_details_page.dart
git commit -m "feat: constrain video player height in SceneDetailsPage"
```

### Task 3: Regression Testing and Validation

**Files:**
- Modify: `test/features/scenes/video_player_ui_test.dart`

- [ ] **Step 1: Update or add a test case to verify height constraints**
Ensure that the `SceneVideoPlayer` does not exceed the calculated safe height when rendered in a `SceneDetailsPage`.

```dart
// test/features/scenes/video_player_ui_test.dart (Hypothetical addition)
testWidgets('SceneDetailsPage constrains video height', (tester) async {
  // Set a specific screen size
  tester.view.physicalSize = const Size(1000, 2000);
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Override providers to return a vertical scene if needed
      ],
      child: MaterialApp(
        home: SceneDetailsPage(sceneId: 'test-scene'),
      ),
    ),
  );

  final playerFinder = find.byType(SceneVideoPlayer);
  final playerSize = tester.getSize(playerFinder);

  // Safe height: 2000 (total) - 0 (padding) - 56 (appbar) - 20 (margin) = 1924
  expect(playerSize.height, lessThanOrEqualTo(1924));
});
```

- [ ] **Step 2: Run tests**
Run: `flutter test test/features/scenes/video_player_ui_test.dart`
Expected: PASS

- [ ] **Step 3: Commit tests**
```bash
git add test/features/scenes/video_player_ui_test.dart
git commit -m "test: verify video player height constraints"
```
