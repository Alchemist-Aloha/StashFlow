# Material 3 UI Refinement (Rounded Corners) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the UI to follow Material 3 design standards by increasing corner radii for cards, buttons, input fields, and bottom sheets.

**Architecture:** Centralized theme updates in `AppTheme` and targeted widget refinements for image clipping and custom card-like behaviors.

**Tech Stack:** Flutter, Material 3.

---

### Task 1: Update Theme Constants

**Files:**
- Modify: `lib/core/presentation/theme/app_theme.dart`

- [ ] **Step 1: Increase radius constants to M3 standards**

```dart
// lib/core/presentation/theme/app_theme.dart

  static const radiusSmall = 8.0;
  static const radiusMedium = 12.0;
  static const radiusLarge = 16.0;
  static const radiusExtraLarge = 28.0; // New constant for bottom sheets
```

- [ ] **Step 2: Update CardTheme and InputDecorationTheme to use radiusMedium (12.0)**

(Ensure they already use `radiusMedium`, which is now 12.0)

- [ ] **Step 3: Commit**

```bash
git add lib/core/presentation/theme/app_theme.dart
git commit -m "theme: update radius constants to Material 3 standards"
```

---

### Task 2: Refine SceneCard with Rounded Corners

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_card.dart`

- [ ] **Step 1: Apply ClipRRect to images in _buildListCard and _buildGridCard**

Wrap the `Image.network` (and its parent `Stack` or `AspectRatio`) with `ClipRRect` using `AppTheme.radiusMedium`.

- [ ] **Step 2: Use Card widget or ensure InkWell has correct borderRadius**

```dart
// lib/features/scenes/presentation/widgets/scene_card.dart

// In _buildListCard and _buildGridCard
return InkWell(
  onTap: onTap,
  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
  onLongPress: () => _showMenu(context, ref),
  // ...
);
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/scenes/presentation/widgets/scene_card.dart
git commit -m "ui: add rounded corners to SceneCard images and inkwells"
```

---

### Task 3: Refine Bottom Sheets with M3 Corners

**Files:**
- Modify: `lib/features/scenes/presentation/pages/scenes_page.dart`
- Modify: `lib/features/scenes/presentation/widgets/scene_filter_panel.dart`
- Modify: `lib/features/performers/presentation/pages/performers_page.dart`
- Modify: `lib/features/studios/presentation/pages/studios_page.dart`
- Modify: `lib/features/tags/presentation/pages/tags_page.dart`

- [ ] **Step 1: Update all showModalBottomSheet builders to use radiusExtraLarge (28.0)**

Search for `top: Radius.circular(AppTheme.radiusLarge)` and replace with `top: Radius.circular(AppTheme.radiusExtraLarge)`.

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenes/presentation/pages/scenes_page.dart lib/features/scenes/presentation/widgets/scene_filter_panel.dart lib/features/performers/presentation/pages/performers_page.dart lib/features/studios/presentation/pages/studios_page.dart lib/features/tags/presentation/pages/tags_page.dart
git commit -m "ui: update bottom sheets to use Material 3 extra-large rounded corners"
```

---

### Task 4: Final Verification

- [ ] **Step 1: Run flutter analyze**

Run: `flutter analyze`
Expected: PASS

- [ ] **Step 2: Build release APK to verify visual consistency**

Run: `flutter build apk --release`
Expected: SUCCESS

- [ ] **Step 3: Commit**

```bash
git commit -m "chore: final Material 3 UI refinement verification"
```
