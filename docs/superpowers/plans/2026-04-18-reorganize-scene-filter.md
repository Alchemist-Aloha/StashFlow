# Reorganize Scene Filter & Expand Organized Filter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the `SceneFilterPanel` into logical sections and upgrade the "Organized" filter to support All/Organized/Unorganized across all media types.

**Architecture:** 
- Define a central `OrganizedFilter` enum in core.
- Update Riverpod providers to use the enum and persist its state.
- Update repository calls to map enum values to `bool?`.
- Refactor UI panels to use `ChoiceChip` for organized selection and logical grouping for scenes.

**Tech Stack:** Flutter, Riverpod, SharedPreferences.

---

### Task 1: Core Data Structures

**Files:**
- Create: `lib/core/domain/entities/filter_options.dart`

- [ ] **Step 1: Define the `OrganizedFilter` enum**

```dart
enum OrganizedFilter {
  all,
  organized,
  unorganized;

  bool? toBool() => switch (this) {
        OrganizedFilter.all => null,
        OrganizedFilter.organized => true,
        OrganizedFilter.unorganized => false,
      };

  static OrganizedFilter fromBool(bool? value) {
    if (value == null) return OrganizedFilter.all;
    return value ? OrganizedFilter.organized : OrganizedFilter.unorganized;
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/domain/entities/filter_options.dart
git commit -m "feat(core): add OrganizedFilter enum"
```

### Task 2: Update Providers (Scenes, Galleries, Images)

**Files:**
- Modify: `lib/features/scenes/presentation/providers/scene_list_provider.dart`
- Modify: `lib/features/galleries/presentation/providers/gallery_list_provider.dart`
- Modify: `lib/features/images/presentation/providers/image_list_provider.dart`

- [ ] **Step 1: Update `SceneOrganizedOnly` provider**

Modify `SceneOrganizedOnly` in `lib/features/scenes/presentation/providers/scene_list_provider.dart` to use `OrganizedFilter`. Update `build`, `set`, and `saveAsDefault`.

```dart
@Riverpod(keepAlive: true)
class SceneOrganizedOnly extends _$SceneOrganizedOnly {
  static const _organizedKey = 'scene_organized_only_v2';

  @override
  OrganizedFilter build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final val = prefs.getString(_organizedKey);
    return OrganizedFilter.values.firstWhere(
      (e) => e.name == val,
      orElse: () => OrganizedFilter.all,
    );
  }

  void set(OrganizedFilter value) => state = value;

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_organizedKey, state.name);
  }
}
```

- [ ] **Step 2: Update `SceneList` build and pagination logic**

Update calls to `repository.findScenes` to use `organized: organizedOnly.toBool()`.

- [ ] **Step 3: Repeat Step 1 & 2 for Galleries and Images**

Update `GalleryOrganizedOnly` and `ImageOrganizedOnly` similarly in their respective provider files.

- [ ] **Step 4: Commit**

```bash
git add lib/features/scenes/presentation/providers/scene_list_provider.dart \
        lib/features/galleries/presentation/providers/gallery_list_provider.dart \
        lib/features/images/presentation/providers/image_list_provider.dart
git commit -m "refactor: update organized providers to use OrganizedFilter enum"
```

### Task 3: Reorganize SceneFilterPanel UI

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_filter_panel.dart`

- [ ] **Step 1: Update `_SceneFilterPanelState` variables**

Change `_tempOrganizedOnly` type to `OrganizedFilter`.

- [ ] **Step 2: Refactor `_buildGeneralSection`**

Keep only Rating and Organized. Use `ChoiceChip` for Organized.

- [ ] **Step 3: Create and implement new sections**

Implement `_buildPerformerSection`, `_buildLibrarySection`, `_buildMetadataSection`, `_buildUsageSection`, etc., moving fields according to the design spec.

- [ ] **Step 4: Update Reset logic**

Ensure `_tempOrganizedOnly` resets to `OrganizedFilter.all`.

- [ ] **Step 5: Commit**

```bash
git add lib/features/scenes/presentation/widgets/scene_filter_panel.dart
git commit -m "feat(scenes): reorganize filter panel and update organized UI"
```

### Task 4: Update Other Filter Panels UI

**Files:**
- Modify: `lib/features/galleries/presentation/widgets/gallery_filter_panel.dart`
- Modify: `lib/features/images/presentation/widgets/image_filter_panel.dart`
- Modify: `lib/features/studios/presentation/widgets/studio_filter_panel.dart`

- [ ] **Step 1: Update `_buildOrganizedFilter` in all panels**

Replace `_buildBooleanFilter` or `Switch` with `ChoiceChip`s for the three states.

- [ ] **Step 2: For Studios, use `_tempFilter.organized`**

Since `StudioFilter` has `organized` field, update `_buildOrganizedFilter` to use `ChoiceChip`s and update `_tempFilter.organized` with `bool?`.

- [ ] **Step 3: Commit**

```bash
git add lib/features/galleries/presentation/widgets/gallery_filter_panel.dart \
        lib/features/images/presentation/widgets/image_filter_panel.dart \
        lib/features/studios/presentation/widgets/studio_filter_panel.dart
git commit -m "feat: update organized filter UI across all media panels"
```

### Task 5: Verification

- [ ] **Step 1: Verify Scene filtering**

Test All/Organized/Unorganized in Scenes tab. Verify results in logs or UI.

- [ ] **Step 2: Verify Gallery/Image/Studio filtering**

Repeat verification for other media types.

- [ ] **Step 3: Verify Persistence**

Save as Default and restart app (or re-load page) to ensure state is preserved.
