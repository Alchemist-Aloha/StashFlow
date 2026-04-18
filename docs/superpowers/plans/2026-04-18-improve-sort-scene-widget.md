# Improve Sort Scene Widget Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve the sort scene widget by making the "Sort method" section scrollable and ensuring action buttons are always visible.

**Architecture:** Use a `Flexible` widget with a `ConstrainedBox` and `SingleChildScrollView` inside the bottom sheet's `Column`. This constrains the sort field selection while keeping header and footer buttons fixed.

**Tech Stack:** Flutter, Riverpod (for state management in `ScenesPage`).

---

### Task 1: Create Reproduction/Verification Test

**Files:**
- Create: `test/features/scenes/presentation/pages/scenes_page_sort_test.dart`

- [ ] **Step 1: Write a widget test to verify sort panel structure**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scenes_page.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('Sort panel should have scrollable sort methods and visible buttons', (tester) async {
    await pumpTestWidget(tester, child: const ScenesPage());
    
    // Open sort panel
    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Sort Scenes'), findsOneWidget);
    
    // Verify Apply Sort button is visible
    expect(find.text('Apply Sort'), findsOneWidget);
    
    // Verify "Sort method" section exists
    expect(find.text('Sort method'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify current state**

Run: `flutter test test/features/scenes/presentation/pages/scenes_page_sort_test.dart`
Expected: PASS (current implementation works, but we want to ensure it stays visible on small screens).

- [ ] **Step 3: Commit**

```bash
git add test/features/scenes/presentation/pages/scenes_page_sort_test.dart
git commit -m "test: add initial sort panel widget test"
```

### Task 2: Implement Scrollable Sort Method Section

**Files:**
- Modify: `lib/features/scenes/presentation/pages/scenes_page.dart`

- [ ] **Step 1: Update `_showSortPanel` with constrained scrollable section**

Modify `_showSortPanel` in `lib/features/scenes/presentation/pages/scenes_page.dart`:
Replace the `Wrap` widget and its surrounding spacing with a `Flexible` container containing a `ConstrainedBox`, `Scrollbar`, and `SingleChildScrollView`.

```dart
// Inside _showSortPanel StatefulBuilder
children: [
  // ... Header Row ...
  const SizedBox(height: AppTheme.spacingMedium),
  Text(
    context.l10n.common_sort_method,
    style: context.textTheme.labelLarge,
  ),
  const SizedBox(height: AppTheme.spacingSmall),
  Flexible(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
          child: Wrap(
            spacing: AppTheme.spacingSmall,
            runSpacing: AppTheme.spacingSmall,
            children: _SceneSortField.values
                .map(
                  (field) => ChoiceChip(
                    label: Text(_sortFieldLabel(field)),
                    selected: tempField == field,
                    onSelected: (selected) {
                      if (!selected) return;
                      setModalState(() {
                        tempField = field;
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    ),
  ),
  const SizedBox(height: AppTheme.spacingMedium),
  Text(
    context.l10n.common_direction,
    style: context.textTheme.labelLarge,
  ),
  // ... rest of the column ...
]
```

- [ ] **Step 2: Verify buttons are still reachable**

Ensure the `SegmentedButton` and action buttons are outside the `Flexible` widget to remain fixed.

- [ ] **Step 3: Run the tests**

Run: `flutter test test/features/scenes/presentation/pages/scenes_page_sort_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/features/scenes/presentation/pages/scenes_page.dart
git commit -m "feat(scenes): make sort method section scrollable in sort panel"
```

### Task 3: Final Verification on Small Screen Simulation

- [ ] **Step 1: Update test to simulate small screen**

```dart
  testWidgets('Sort panel buttons should be visible on small screens', (tester) async {
    // Set small screen size (e.g., iPhone SE or similar)
    tester.view.physicalSize = const Size(320 * 3, 480 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await pumpTestWidget(tester, child: const ScenesPage());
    
    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();

    // Verify buttons are still in the viewport
    expect(find.text('Apply Sort'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
    
    // Check if the Apply Sort button is actually visible (not obscured)
    final applyButton = find.text('Apply Sort');
    expect(tester.getCenter(applyButton).dy, lessThan(480)); 
  });
```

- [ ] **Step 2: Run the updated tests**

Run: `flutter test test/features/scenes/presentation/pages/scenes_page_sort_test.dart`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add test/features/scenes/presentation/pages/scenes_page_sort_test.dart
git commit -m "test: verify button visibility on small screens"
```
