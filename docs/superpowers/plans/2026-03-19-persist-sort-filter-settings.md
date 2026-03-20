# Persist Sorting and Filtering Settings Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow users to save their current sorting and filtering preferences as defaults that persist across app restarts.

**Architecture:** Use `SharedPreferences` to store JSON-serialized filter objects and simple sort configurations. Providers will initialize their state from `SharedPreferences` and provide `saveAsDefault` methods.

**Tech Stack:** Flutter, Riverpod, SharedPreferences, Freezed, JsonSerializable.

---

### Task 1: Enable JSON Serialization for SceneFilter

**Files:**
- Modify: `lib/features/scenes/domain/entities/scene_filter.dart`

- [ ] **Step 1: Add JsonSerializable annotations and fromJson factory**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scene_filter.freezed.dart';
part 'scene_filter.g.dart'; // Add this

@freezed
class SceneFilter with _$SceneFilter {
  const factory SceneFilter({
    String? searchQuery,
    int? minRating,
    String? studioId,
    List<String>? performerIds,
    List<String>? includeTags,
    List<String>? excludeTags,
    bool? isWatched,
    DateTime? startDate,
    DateTime? endDate,
  }) = _SceneFilter;

  factory SceneFilter.empty() => const SceneFilter();

  factory SceneFilter.fromJson(Map<String, dynamic> json) =>
      _$SceneFilterFromJson(json);
}
```

- [ ] **Step 2: Run build_runner to generate .g.dart file**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: SUCCESS

- [ ] **Step 3: Commit**

```bash
git add lib/features/scenes/domain/entities/scene_filter.dart
git commit -m "feat: add JSON serialization to SceneFilter"
```

---

### Task 2: Implement Persistence in Scene Providers

**Files:**
- Modify: `lib/features/scenes/presentation/providers/scene_list_provider.dart`

- [ ] **Step 1: Update SceneSort to load/save from SharedPreferences**

```dart
@riverpod
class SceneSort extends _$SceneSort {
  static const _sortKey = 'scene_sort_field';
  static const _descKey = 'scene_sort_descending';

  @override
  ({String? sort, bool descending}) build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'date';
    final descending = prefs.getBool(_descKey) ?? true;
    return (sort: sort, descending: descending);
  }

  void setSort({String? sort, bool descending = true}) {
    state = (sort: sort, descending: descending);
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (state.sort != null) await prefs.setString(_sortKey, state.sort!);
    await prefs.setBool(_descKey, state.descending);
  }
}
```

- [ ] **Step 2: Update SceneFilterState to load/save from SharedPreferences**

```dart
@riverpod
class SceneFilterState extends _$SceneFilterState {
  static const _storageKey = 'scene_filter_state';

  @override
  SceneFilter build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        return SceneFilter.fromJson(jsonDecode(jsonString));
      } catch (_) {
        return SceneFilter.empty();
      }
    }
    return SceneFilter.empty();
  }

  void update(SceneFilter filter) => state = filter;
  void clear() => state = SceneFilter.empty();

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }
}
```

- [ ] **Step 3: Update SceneOrganizedOnly to load/save**

```dart
class SceneOrganizedOnly extends Notifier<bool> {
  static const _storageKey = 'scene_organized_only';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? false;
  }

  void set(bool value) => state = value;

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, state);
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/scenes/presentation/providers/scene_list_provider.dart
git commit -m "feat: add persistence to scene sort and filter providers"
```

---

### Task 3: Update ScenesPage UI for Saving Defaults

**Files:**
- Modify: `lib/features/scenes/presentation/pages/scenes_page.dart`
- Modify: `lib/features/scenes/presentation/widgets/scene_filter_panel.dart`

- [ ] **Step 1: Add "Save as Default" button to Sort panel in ScenesPage**

Add a button next to "Apply Sort" or at the bottom of the panel.

- [ ] **Step 2: Add "Save as Default" button to SceneFilterPanel**

Add a button next to "Apply Filters".

- [ ] **Step 3: Commit**

```bash
git add lib/features/scenes/presentation/pages/scenes_page.dart lib/features/scenes/presentation/widgets/scene_filter_panel.dart
git commit -m "ui: add Save as Default buttons to scene sort and filter panels"
```

---

### Task 4: Implement Persistence for Performers

**Files:**
- Modify: `lib/features/performers/presentation/providers/performer_list_provider.dart`
- Modify: `lib/features/performers/presentation/pages/performers_page.dart`

- [ ] **Step 1: Update PerformerSort with persistence**
- [ ] **Step 2: Update PerformerFavoritesOnlyNotifier with persistence**
- [ ] **Step 3: Add "Save as Default" button to Sort panel in PerformersPage**

- [ ] **Step 4: Commit**

```bash
git add lib/features/performers/presentation/providers/performer_list_provider.dart lib/features/performers/presentation/pages/performers_page.dart
git commit -m "feat: add persistence and UI for performer sort defaults"
```

---

### Task 5: Implement Persistence for Studios

**Files:**
- Modify: `lib/features/studios/presentation/providers/studio_list_provider.dart`
- Modify: `lib/features/studios/presentation/pages/studios_page.dart`

- [ ] **Step 1: Extract StudioSort to a separate provider with persistence**
- [ ] **Step 2: Update StudioFavoritesOnlyNotifier with persistence**
- [ ] **Step 3: Add "Save as Default" buttons to StudiosPage sort/filter panels**

- [ ] **Step 4: Commit**

```bash
git add lib/features/studios/presentation/providers/studio_list_provider.dart lib/features/studios/presentation/pages/studios_page.dart
git commit -m "feat: add persistence and UI for studio sort/filter defaults"
```

---

### Task 6: Final Verification

- [ ] **Step 1: Verify all features**
    - Change sort/filter in Scenes, save as default, restart app (or re-trigger build), verify state is loaded.
    - Repeat for Performers and Studios.
- [ ] **Step 2: Run tests**
    - `flutter test`
- [ ] **Step 3: Commit**
    - `git commit -m "chore: final verification of persisted settings"`
