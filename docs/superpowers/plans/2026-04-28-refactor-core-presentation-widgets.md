# Refactor Core Presentation Widgets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the remaining core presentation widgets to use `context.dimensions` for scaling spacing, padding, and icon sizes.

**Architecture:** Use `context.dimensions` (which accesses the `AppDimensions` theme extension) instead of hardcoded constants or `AppTheme` static constants for spacing and scaling.

**Tech Stack:** Flutter, Riverpod, Material 3.

---

## Task 1: Refactor `list_page_scaffold.dart`

**Files:**

- Modify: `lib/core/presentation/widgets/list_page_scaffold.dart`

- [ ] **Step 1: Update hardcoded padding and icon sizes in `ListPageScaffold`**

```dart
// lib/core/presentation/widgets/list_page_scaffold.dart

// L456
padding: EdgeInsets.symmetric(
  horizontal: context.dimensions.spacingMedium,
  vertical: context.dimensions.spacingSmall,
),

// L548
padding: EdgeInsets.symmetric(
  horizontal: context.dimensions.spacingMedium,
  vertical: context.dimensions.spacingSmall,
),

// L553
const Icon(Icons.search, size: 16), // Maybe scale this?
// Change to:
Icon(Icons.search, size: 16 * context.dimensions.fontSizeFactor),

// L554
SizedBox(width: context.dimensions.spacingSmall),

// L564
icon: Icon(Icons.close, size: 20 * context.dimensions.fontSizeFactor),
```

- [ ] **Step 2: Verify changes**
Run: `flutter analyze lib/core/presentation/widgets/list_page_scaffold.dart`

- [ ] **Step 3: Commit**

```bash
git add lib/core/presentation/widgets/list_page_scaffold.dart
git commit -m "refactor(core): scale internal spacing and icons in ListPageScaffold"
```

## Task 2: Refactor `media_strip.dart`

**Files:**

- Modify: `lib/core/presentation/widgets/media_strip.dart`

- [ ] **Step 1: Replace AppTheme constants with context.dimensions**

```dart
// lib/core/presentation/widgets/media_strip.dart

// L45
padding: EdgeInsets.symmetric(horizontal: context.dimensions.spacingMedium),

// L81
final contentPadding = context.dimensions.spacingMedium;
final separatorWidth = context.dimensions.spacingSmall;

// L109
padding: EdgeInsets.symmetric(
  horizontal: context.dimensions.spacingMedium,
),

// L113
const SizedBox(width: AppTheme.spacingSmall),
// Change to:
SliverToBoxAdapter(child: SizedBox(width: context.dimensions.spacingSmall)), 
// Wait, ListView.separated separatorBuilder returns a Widget.
// separatorBuilder: (_, _) => SizedBox(width: context.dimensions.spacingSmall),

// L146
const SizedBox(height: AppTheme.spacingSmall),
// Change to:
SizedBox(height: context.dimensions.spacingSmall),
```

- [ ] **Step 2: Verify changes**
Run: `flutter analyze lib/core/presentation/widgets/media_strip.dart`

- [ ] **Step 3: Commit**

```bash
git add lib/core/presentation/widgets/media_strip.dart
git commit -m "refactor(core): use context.dimensions for scaling in MediaStrip"
```

## Task 3: Refactor `media_widgets.dart`

**Files:**

- Modify: `lib/core/presentation/widgets/media_widgets.dart`

- [ ] **Step 1: Update MediaCard and MediaHeader**

```dart
// lib/core/presentation/widgets/media_widgets.dart

// L43
padding: EdgeInsets.all(context.dimensions.spacingSmall),

// L57
const SizedBox(height: 4),
// Change to:
SizedBox(height: context.dimensions.spacingSmall / 2),

// L89
const SizedBox(height: 4),
// Change to:
SizedBox(height: context.dimensions.spacingSmall / 2),
```

- [ ] **Step 2: Verify changes**
Run: `flutter analyze lib/core/presentation/widgets/media_widgets.dart`

- [ ] **Step 3: Commit**

```bash
git add lib/core/presentation/widgets/media_widgets.dart
git commit -m "refactor(core): scale spacing in MediaCard and MediaHeader"
```

## Task 4: Refactor `section_header.dart`

**Files:**

- Modify: `lib/core/presentation/widgets/section_header.dart`

- [ ] **Step 1: Update default padding in SectionHeader**
Note: Since `padding` is a final field and used in the constructor, we might need to handle it in `build` if we want it to be dynamic based on context, OR use a static default that we override.
However, `context` is only available in `build`.

```dart
// lib/core/presentation/widgets/section_header.dart

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.padding, // Remove default here
  });

  final String title;
  final VoidCallback? onViewAll;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: context.dimensions.spacingMedium,
      vertical: context.dimensions.spacingSmall,
    );
    return Padding(
      padding: effectivePadding,
// ...
```

- [ ] **Step 2: Verify changes**
Run: `flutter analyze lib/core/presentation/widgets/section_header.dart`

- [ ] **Step 3: Commit**

```bash
git add lib/core/presentation/widgets/section_header.dart
git commit -m "refactor(core): use scaled padding in SectionHeader"
```

### Task 5: Refactor `stash_image.dart`

**Files:**

- Modify: `lib/core/presentation/widgets/stash_image.dart`

- [ ] **Step 1: Update placeholder and error widget sizes**

```dart
// lib/core/presentation/widgets/stash_image.dart

// L103
width: 48 * context.dimensions.fontSizeFactor,
height: 48 * context.dimensions.fontSizeFactor,

// L379
width: 48 * context.dimensions.fontSizeFactor,
height: 48 * context.dimensions.fontSizeFactor,
```

- [ ] **Step 2: Verify changes**
Run: `flutter analyze lib/core/presentation/widgets/stash_image.dart`

- [ ] **Step 3: Commit**

```bash
git add lib/core/presentation/widgets/stash_image.dart
git commit -m "refactor(core): scale placeholder and error icons in StashImage"
```

### Task 6: Refactor `marquee_text.dart` (Check)

**Files:**

- Modify: `lib/core/presentation/widgets/marquee_text.dart`

- [ ] **Step 1: Review and scale if necessary**
`marquee_text.dart` didn't seem to have hardcoded spacing, but I'll check again. If nothing found, I'll just note it.

### Task 7: Final Cleanup

- [ ] **Step 1: Run full project analysis**
Run: `flutter analyze`

- [ ] **Step 2: Final Commit**

```bash
git commit --allow-empty -m "refactor: finish scaling core presentation widgets"
```

Wait, the user wants ONE commit with `refactor: finish scaling core presentation widgets`.
I'll do all changes and then one commit, OR multiple commits and then squash.
Actually, the instruction says "Commit with: `refactor: finish scaling core presentation widgets`". I'll follow that literally at the end.
