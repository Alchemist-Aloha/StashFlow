# Material 3 UI Further Refinement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Further refine the UI to adhere to Material 3 design principles, focusing on typography, button styles, segmented buttons, and advanced app bar behaviors.

**Architecture:** Update `AppTheme` for better M3 defaults and modernize key widgets (`ListPageScaffold`, `ErrorStateView`, and sort panels).

**Tech Stack:** Flutter, Material 3.

---

### Task 1: Update Theme for M3 Typography and Buttons

**Files:**
- Modify: `lib/core/presentation/theme/app_theme.dart`

- [ ] **Step 1: Add SegmentedButtonThemeData and update button themes**

```dart
// lib/core/presentation/theme/app_theme.dart

// Inside _buildTheme:
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: colorScheme.primaryContainer,
          selectedForegroundColor: colorScheme.onPrimaryContainer,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ),
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/presentation/theme/app_theme.dart
git commit -m "theme: add SegmentedButton theme and update button defaults for M3"
```

---

### Task 2: Modernize ErrorStateView

**Files:**
- Modify: `lib/core/presentation/widgets/error_state_view.dart`

- [ ] **Step 1: Use M3 typography and FilledButton.tonal**

```dart
// lib/core/presentation/widgets/error_state_view.dart

// ...
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.tonal(onPressed: onRetry, child: Text(retryLabel)),
            ],
// ...
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/presentation/widgets/error_state_view.dart
git commit -m "ui: modernize ErrorStateView with Material 3 styling"
```

---

### Task 3: Implement SegmentedButtons in Sort Panels

**Files:**
- Modify: `lib/features/scenes/presentation/pages/scenes_page.dart`
- Modify: `lib/features/performers/presentation/pages/performers_page.dart`
- Modify: `lib/features/studios/presentation/pages/studios_page.dart`
- Modify: `lib/features/tags/presentation/pages/tags_page.dart`

- [ ] **Step 1: Replace Direction ChoiceChips with SegmentedButton in ScenesPage**

```dart
// lib/features/scenes/presentation/pages/scenes_page.dart

                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Descending'), icon: Icon(Icons.arrow_downward)),
                      ButtonSegment(value: false, label: Text('Ascending'), icon: Icon(Icons.arrow_upward)),
                    ],
                    selected: {tempDescending},
                    onSelectionChanged: (value) => setModalState(() => tempDescending = value.first),
                  ),
```

- [ ] **Step 2: Repeat for Performers, Studios, and Tags pages**

- [ ] **Step 3: Commit**

```bash
git add lib/features/scenes/presentation/pages/scenes_page.dart lib/features/performers/presentation/pages/performers_page.dart lib/features/studios/presentation/pages/studios_page.dart lib/features/tags/presentation/pages/tags_page.dart
git commit -m "ui: use SegmentedButton for sort direction in list pages"
```

---

### Task 4: Modernize ListPageScaffold with M3 App Bar behavior

**Files:**
- Modify: `lib/core/presentation/widgets/list_page_scaffold.dart`

- [ ] **Step 1: Enable scrolledUnderElevation and distinct color**

```dart
// lib/core/presentation/widgets/list_page_scaffold.dart

      appBar: AppBar(
        scrolledUnderElevation: 4.0,
        // ...
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/presentation/widgets/list_page_scaffold.dart
git commit -m "ui: enable M3 scrolled-under behavior in ListPageScaffold"
```

---

### Task 5: Final Release Build

- [ ] **Step 1: Run all tests**

Run: `flutter test`
Expected: PASS

- [ ] **Step 2: Build release APK**

Run: `flutter build apk --release`
Expected: SUCCESS

- [ ] **Step 3: Commit**

```bash
git commit -m "chore: final Material 3 UI refinement and release build"
```
