# Scene Saved Presets Panel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle the scene saved presets sheet so it matches the compact Material 3 structure of the sort panel while preserving save/load behavior.

**Architecture:** Keep the existing `SceneSavedFilterDialog` entry point and repository interactions intact, and refactor only the bottom-sheet layout, section hierarchy, and row presentation. Use a widget-test-first loop to lock in the compact sheet height and core Material 3 structure before adjusting the dialog implementation.

**Tech Stack:** Flutter, Material 3 widgets, Riverpod, `flutter_test`

---

### Task 1: Lock the compact-sheet expectations in tests

**Files:**
- Modify: `test/features/scenes/presentation/widgets/scene_saved_filter_dialog_test.dart`

- [ ] **Step 1: Write the failing test**

Add assertions after the sheet opens:

```dart
      expect(find.text('Current Settings'), findsOneWidget);
      expect(find.text('Saved Presets'), findsOneWidget);

      final dialogSize = tester.getSize(find.byType(SceneSavedFilterDialog));
      final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(dialogSize.height, lessThan(screenHeight * 0.8));
```

- [ ] **Step 2: Run test to verify it fails**

Run: `rtk flutter test test/features/scenes/presentation/widgets/scene_saved_filter_dialog_test.dart`
Expected: FAIL because the current sheet is ~90% of screen height and does not expose the new section heading.

- [ ] **Step 3: Commit**

```bash
git add test/features/scenes/presentation/widgets/scene_saved_filter_dialog_test.dart
git commit -m "test: capture compact saved presets sheet layout"
```

### Task 2: Refactor the sheet layout to a compact Material 3 structure

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_saved_filter_dialog.dart`

- [ ] **Step 1: Replace the tall custom shell with a compact content-driven sheet**

Update the root build structure so the sheet uses a constrained `mainAxisSize: MainAxisSize.min` layout with a max-height-bounded presets list rather than a 90% viewport shell.

- [ ] **Step 2: Rework the header and section hierarchy**

Use:

```dart
Text('Saved Presets', style: context.textTheme.headlineSmall?.copyWith(...))
Text('Current Settings', style: context.textTheme.labelLarge)
Text('Available Presets', style: context.textTheme.labelLarge)
```

Keep the header save action and close action, but align spacing and visual weight with the sort panel.

- [ ] **Step 3: Tighten the summary surface and presets list presentation**

Use a compact tonal summary block and a bounded `Scrollbar` + `ListView.separated` region for presets. Keep save/load behavior unchanged.

- [ ] **Step 4: Run the widget test to verify it passes**

Run: `rtk flutter test test/features/scenes/presentation/widgets/scene_saved_filter_dialog_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/scenes/presentation/widgets/scene_saved_filter_dialog.dart test/features/scenes/presentation/widgets/scene_saved_filter_dialog_test.dart
git commit -m "feat: restyle scene saved presets sheet"
```

### Task 3: Verify saved-filter behavior still holds

**Files:**
- Test: `test/features/scenes/data/repositories/graphql_scene_saved_filter_repository_test.dart`
- Test: `test/features/scenes/domain/scene_saved_filter_config_test.dart`

- [ ] **Step 1: Run related saved-filter tests**

Run: `rtk flutter test test/features/scenes/presentation/widgets/scene_saved_filter_dialog_test.dart test/features/scenes/data/repositories/graphql_scene_saved_filter_repository_test.dart test/features/scenes/domain/scene_saved_filter_config_test.dart`
Expected: PASS

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenes/presentation/widgets/scene_saved_filter_dialog.dart test/features/scenes/presentation/widgets/scene_saved_filter_dialog_test.dart
git commit -m "test: verify saved presets panel refresh"
```
