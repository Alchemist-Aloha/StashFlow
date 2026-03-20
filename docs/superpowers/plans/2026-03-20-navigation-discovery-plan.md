# Navigation and Discovery Enhancements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a global setting to toggle random navigation buttons and expand sorting/filtering for Performers, Studios, and Tags.

**Architecture:** Use Riverpod for state management, SharedPreferences for persistence, and update existing list/details pages.

**Tech Stack:** Flutter, Riverpod, GraphQL.

---

### Task 1: Navigation Customization State

**Files:**
- Create: `lib/features/setup/presentation/providers/navigation_customization_provider.dart`
- Modify: `lib/features/setup/presentation/settings_page.dart`

- [ ] **Step 1: Create the provider**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';

part 'navigation_customization_provider.g.dart';

@riverpod
class RandomNavigationEnabled extends _$RandomNavigationEnabled {
  static const _storageKey = 'show_random_navigation';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? true;
  }

  void set(bool value) {
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_storageKey, value);
  }
}
```

- [ ] **Step 2: Add toggle to SettingsPage**
Modify `lib/features/setup/presentation/settings_page.dart` to include the switch under a "Navigation" section.

- [ ] **Step 3: Commit**
```bash
git add lib/features/setup/presentation/providers/navigation_customization_provider.dart lib/features/setup/presentation/settings_page.dart
git commit -m "feat: add global toggle for random navigation buttons"
```

---

### Task 2: Conditionally Show Random Buttons in List Pages

**Files:**
- Modify: `lib/features/scenes/presentation/pages/scenes_page.dart`
- Modify: `lib/features/performers/presentation/pages/performers_page.dart`
- Modify: `lib/features/studios/presentation/pages/studios_page.dart`
- Modify: `lib/features/tags/presentation/pages/tags_page.dart`

- [ ] **Step 1: Update ScenesPage**
Watch `randomNavigationEnabledProvider` and conditionally show `floatingActionButton`.

- [ ] **Step 2: Update PerformersPage**
Watch `randomNavigationEnabledProvider` and conditionally show `floatingActionButton`.

- [ ] **Step 3: Update StudiosPage**
Watch `randomNavigationEnabledProvider` and conditionally show `floatingActionButton`.

- [ ] **Step 4: Update TagsPage**
Watch `randomNavigationEnabledProvider` and conditionally show `floatingActionButton`.

- [ ] **Step 5: Commit**
```bash
git add lib/features/scenes/presentation/pages/scenes_page.dart lib/features/performers/presentation/pages/performers_page.dart lib/features/studios/presentation/pages/studios_page.dart lib/features/tags/presentation/pages/tags_page.dart
git commit -m "ui: conditionally show random FABs on list pages"
```

---

### Task 3: Conditionally Show Random Buttons in Details Pages

**Files:**
- Modify: `lib/features/scenes/presentation/pages/scene_details_page.dart`
- Modify: `lib/features/performers/presentation/pages/performer_details_page.dart`
- Modify: `lib/features/studios/presentation/pages/studio_details_page.dart`
- Modify: `lib/features/tags/presentation/pages/tag_details_page.dart`

- [ ] **Step 1: Update Details Pages**
Repeat the conditional logic for `floatingActionButton` in all four details pages.

- [ ] **Step 2: Commit**
```bash
git add lib/features/scenes/presentation/pages/scene_details_page.dart lib/features/performers/presentation/pages/performer_details_page.dart lib/features/studios/presentation/pages/studio_details_page.dart lib/features/tags/presentation/pages/tag_details_page.dart
git commit -m "ui: conditionally show random FABs on details pages"
```

---

### Task 4: Advanced Discovery - Performers

**Files:**
- Modify: `lib/features/performers/presentation/pages/performers_page.dart`
- Modify: `lib/features/performers/presentation/providers/performer_list_provider.dart`

- [ ] **Step 1: Expand _PerformerSortOption enum**
Add `rating`, `playCount`, `oCounter`, `createdAt`, `updatedAt`, `sceneCount`, `imageCount`, `galleryCount`.

- [ ] **Step 2: Update UI and Sort Logic**
Update `_sortLabel`, `_applyServerSort`, and the sort panel.

- [ ] **Step 3: (Optional but recommended) Add more filters**
Expand the filter panel with basic attributes like Gender.

- [ ] **Step 4: Commit**
```bash
git add lib/features/performers/presentation/pages/performers_page.dart lib/features/performers/presentation/providers/performer_list_provider.dart
git commit -m "feat: advanced sorting and filtering for performers"
```

---

### Task 5: Advanced Discovery - Studios and Tags

**Files:**
- Modify: `lib/features/studios/presentation/pages/studios_page.dart`
- Modify: `lib/features/tags/presentation/pages/tags_page.dart`

- [ ] **Step 1: Expand sorting for Studios**
Add `rating`, `performerCount`, `imageCount`, `galleryCount`, `groupCount`, `createdAt`, `updatedAt`.

- [ ] **Step 2: Expand sorting for Tags**
Add `performerCount`, `markerCount`, `parentCount`, `childCount`, `createdAt`, `updatedAt`.

- [ ] **Step 3: Commit**
```bash
git add lib/features/studios/presentation/pages/studios_page.dart lib/features/tags/presentation/pages/tags_page.dart
git commit -m "feat: advanced sorting for studios and tags"
```
