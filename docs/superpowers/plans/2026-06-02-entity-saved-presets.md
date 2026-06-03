# Entity Saved Presets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add scene-style named saved presets to performers, studios, tags, images, and galleries using the server saved filter system while preserving existing scene behavior.

**Architecture:** Extract the scene-only saved preset flow into a shared mode-aware repository, config adapter layer, and reusable bottom-sheet widget. Then wire each target page into that layer with per-feature state mapping so loading a preset restores the same effective query, sort, and filter state the page already uses.

**Tech Stack:** Flutter, Material 3, Riverpod, GraphQL, `flutter_test`

---

### Task 1: Lock mode-aware saved preset contracts in tests

**Files:**
- Create: `test/core/data/repositories/graphql_saved_filter_repository_test.dart`
- Create: `test/core/domain/entities/saved_filter_config_test.dart`
- Modify: `test/features/scenes/data/repositories/graphql_scene_saved_filter_repository_test.dart`
- Modify: `test/features/scenes/domain/scene_saved_filter_config_test.dart`

- [ ] **Step 1: Write the failing repository test for generic mode-based loading**

Add a test that asserts the repository queries `findSavedFilters(mode: PERFORMERS)` and preserves saved filter ids and names.

- [ ] **Step 2: Write the failing config round-trip tests**

Add tests that cover:

```dart
expect(config.searchQuery, 'alice');
expect(config.sort, 'rating');
expect(config.descending, isTrue);
expect(config.filterMode, 'PERFORMERS');
```

and that `toSaveInput()` includes the requested mode.

- [ ] **Step 3: Run the new tests to verify they fail**

Run: `rtk flutter test test/core/data/repositories/graphql_saved_filter_repository_test.dart test/core/domain/entities/saved_filter_config_test.dart`
Expected: FAIL because the shared repository and generic config types do not exist yet.

- [ ] **Step 4: Commit**

```bash
git add test/core/data/repositories/graphql_saved_filter_repository_test.dart test/core/domain/entities/saved_filter_config_test.dart test/features/scenes/data/repositories/graphql_scene_saved_filter_repository_test.dart test/features/scenes/domain/scene_saved_filter_config_test.dart
git commit -m "test: define shared saved preset contracts"
```

### Task 2: Extract the shared saved preset core

**Files:**
- Create: `lib/core/domain/entities/saved_filter_config.dart`
- Create: `lib/core/data/repositories/graphql_saved_filter_repository.dart`
- Modify: `lib/features/scenes/domain/entities/scene_saved_filter_config.dart`
- Modify: `lib/features/scenes/presentation/providers/scene_list_provider.dart`
- Modify: `lib/features/scenes/data/repositories/graphql_scene_saved_filter_repository.dart`

- [ ] **Step 1: Add the shared saved config base type**

Create a mode-aware base model that exposes:

```dart
abstract class SavedFilterConfig<TFilter> {
  String? get id;
  String get name;
  String get filterMode;
  String get searchQuery;
  String? get sort;
  bool get descending;
  TFilter get filter;
  Map<String, dynamic> toSaveInput();
}
```

- [ ] **Step 2: Add the shared GraphQL repository**

Implement a repository with `findAll({required String mode})` and `save(Map<String, dynamic> input)` using the existing saved filter GraphQL documents and payload validation pattern.

- [ ] **Step 3: Rebase scene config/repository on the shared core**

Keep `SceneSavedFilterConfig` as the scene-specific mapper, but route its server fetch/save through the generic repository so scene behavior does not fork.

- [ ] **Step 4: Run the shared-core tests**

Run: `rtk flutter test test/core/data/repositories/graphql_saved_filter_repository_test.dart test/core/domain/entities/saved_filter_config_test.dart test/features/scenes/data/repositories/graphql_scene_saved_filter_repository_test.dart test/features/scenes/domain/scene_saved_filter_config_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/domain/entities/saved_filter_config.dart lib/core/data/repositories/graphql_saved_filter_repository.dart lib/features/scenes/domain/entities/scene_saved_filter_config.dart lib/features/scenes/presentation/providers/scene_list_provider.dart lib/features/scenes/data/repositories/graphql_scene_saved_filter_repository.dart test/core/data/repositories/graphql_saved_filter_repository_test.dart test/core/domain/entities/saved_filter_config_test.dart test/features/scenes/data/repositories/graphql_scene_saved_filter_repository_test.dart test/features/scenes/domain/scene_saved_filter_config_test.dart
git commit -m "refactor: share saved preset repository core"
```

### Task 3: Make the saved presets sheet reusable

**Files:**
- Create: `lib/core/presentation/widgets/saved_filter_dialog.dart`
- Create: `test/core/presentation/widgets/saved_filter_dialog_test.dart`
- Modify: `lib/features/scenes/presentation/widgets/scene_saved_filter_dialog.dart`
- Modify: `test/features/scenes/presentation/widgets/scene_saved_filter_dialog_test.dart`

- [ ] **Step 1: Write the failing reusable dialog widget test**

Add a test that opens the generic dialog, asserts:

```dart
expect(find.text('Current Settings'), findsOneWidget);
expect(find.text('Available Presets'), findsOneWidget);
await tester.tap(find.byIcon(Icons.save_outlined));
expect(find.text('Save Preset'), findsOneWidget);
```

- [ ] **Step 2: Run the widget tests to verify failure**

Run: `rtk flutter test test/core/presentation/widgets/saved_filter_dialog_test.dart test/features/scenes/presentation/widgets/scene_saved_filter_dialog_test.dart`
Expected: FAIL because the shared dialog does not exist yet.

- [ ] **Step 3: Extract the shared dialog and keep the scene wrapper thin**

Move the compact Material 3 sheet implementation into `core`, leaving `SceneSavedFilterDialog` as a small adapter or type alias layer.

- [ ] **Step 4: Re-run the widget tests**

Run: `rtk flutter test test/core/presentation/widgets/saved_filter_dialog_test.dart test/features/scenes/presentation/widgets/scene_saved_filter_dialog_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/presentation/widgets/saved_filter_dialog.dart lib/features/scenes/presentation/widgets/scene_saved_filter_dialog.dart test/core/presentation/widgets/saved_filter_dialog_test.dart test/features/scenes/presentation/widgets/scene_saved_filter_dialog_test.dart
git commit -m "refactor: extract reusable saved preset dialog"
```

### Task 4: Add performer and studio preset support

**Files:**
- Create: `lib/features/performers/domain/entities/performer_saved_filter_config.dart`
- Create: `lib/features/studios/domain/entities/studio_saved_filter_config.dart`
- Create: `test/features/performers/domain/performer_saved_filter_config_test.dart`
- Create: `test/features/studios/domain/studio_saved_filter_config_test.dart`
- Modify: `lib/features/performers/presentation/pages/performers_page.dart`
- Modify: `lib/features/performers/presentation/providers/performer_list_provider.dart`
- Modify: `lib/features/studios/presentation/pages/studios_page.dart`
- Modify: `lib/features/studios/presentation/providers/studio_list_provider.dart`

- [ ] **Step 1: Write the failing config tests for performers and studios**

Each test should assert the saved payload mode and filter restoration:

```dart
expect(input['mode'], 'PERFORMERS');
expect(input['find_filter']['sort'], 'name');
```

and

```dart
expect(input['mode'], 'STUDIOS');
expect(config.filter.favorite, isTrue);
```

- [ ] **Step 2: Run the tests to verify failure**

Run: `rtk flutter test test/features/performers/domain/performer_saved_filter_config_test.dart test/features/studios/domain/studio_saved_filter_config_test.dart`
Expected: FAIL because the config types do not exist.

- [ ] **Step 3: Implement config types and page wiring**

Add bookmark actions and `_applySavedFilterConfig(...)` methods that restore page state and invalidate the list provider after loading.

- [ ] **Step 4: Re-run the tests**

Run: `rtk flutter test test/features/performers/domain/performer_saved_filter_config_test.dart test/features/studios/domain/studio_saved_filter_config_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/performers/domain/entities/performer_saved_filter_config.dart lib/features/studios/domain/entities/studio_saved_filter_config.dart lib/features/performers/presentation/pages/performers_page.dart lib/features/performers/presentation/providers/performer_list_provider.dart lib/features/studios/presentation/pages/studios_page.dart lib/features/studios/presentation/providers/studio_list_provider.dart test/features/performers/domain/performer_saved_filter_config_test.dart test/features/studios/domain/studio_saved_filter_config_test.dart
git commit -m "feat: add performer and studio saved presets"
```

### Task 5: Add tag, image, and gallery preset support

**Files:**
- Create: `lib/features/tags/domain/entities/tag_saved_filter_config.dart`
- Create: `lib/features/images/domain/entities/image_saved_filter_config.dart`
- Create: `lib/features/galleries/domain/entities/gallery_saved_filter_config.dart`
- Create: `test/features/tags/domain/tag_saved_filter_config_test.dart`
- Create: `test/features/images/domain/image_saved_filter_config_test.dart`
- Create: `test/features/galleries/domain/gallery_saved_filter_config_test.dart`
- Modify: `lib/features/tags/presentation/pages/tags_page.dart`
- Modify: `lib/features/tags/presentation/providers/tag_list_provider.dart`
- Modify: `lib/features/images/presentation/pages/images_page.dart`
- Modify: `lib/features/images/presentation/providers/image_list_provider.dart`
- Modify: `lib/features/galleries/presentation/pages/galleries_page.dart`
- Modify: `lib/features/galleries/presentation/providers/gallery_list_provider.dart`

- [ ] **Step 1: Write the failing config tests for tag, image, and gallery edge cases**

Cover the special cases:

```dart
expect(input['mode'], 'TAGS');
expect(config.filter.favorite, isTrue);
```

```dart
expect(input['mode'], 'IMAGES');
expect(config.filter.organized, isTrue);
```

```dart
expect(input['mode'], 'GALLERIES');
expect(config.filter.organized, isFalse);
```

- [ ] **Step 2: Run the tests to verify failure**

Run: `rtk flutter test test/features/tags/domain/tag_saved_filter_config_test.dart test/features/images/domain/image_saved_filter_config_test.dart test/features/galleries/domain/gallery_saved_filter_config_test.dart`
Expected: FAIL because the config types do not exist.

- [ ] **Step 3: Implement config types and page wiring**

Make sure tags include `favoritesOnly`, images merge `imageFilterStateProvider.filter` with `imageOrganizedOnlyProvider`, and galleries merge `galleryFilterStateProvider` with `galleryOrganizedOnlyProvider`.

- [ ] **Step 4: Re-run the tests**

Run: `rtk flutter test test/features/tags/domain/tag_saved_filter_config_test.dart test/features/images/domain/image_saved_filter_config_test.dart test/features/galleries/domain/gallery_saved_filter_config_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/tags/domain/entities/tag_saved_filter_config.dart lib/features/images/domain/entities/image_saved_filter_config.dart lib/features/galleries/domain/entities/gallery_saved_filter_config.dart lib/features/tags/presentation/pages/tags_page.dart lib/features/tags/presentation/providers/tag_list_provider.dart lib/features/images/presentation/pages/images_page.dart lib/features/images/presentation/providers/image_list_provider.dart lib/features/galleries/presentation/pages/galleries_page.dart lib/features/galleries/presentation/providers/gallery_list_provider.dart test/features/tags/domain/tag_saved_filter_config_test.dart test/features/images/domain/image_saved_filter_config_test.dart test/features/galleries/domain/gallery_saved_filter_config_test.dart
git commit -m "feat: add tag image and gallery saved presets"
```

### Task 6: Verify cross-feature behavior

**Files:**
- Test: `test/core/presentation/widgets/saved_filter_dialog_test.dart`
- Test: `test/features/scenes/presentation/widgets/scene_saved_filter_dialog_test.dart`
- Test: `test/features/performers/domain/performer_saved_filter_config_test.dart`
- Test: `test/features/studios/domain/studio_saved_filter_config_test.dart`
- Test: `test/features/tags/domain/tag_saved_filter_config_test.dart`
- Test: `test/features/images/domain/image_saved_filter_config_test.dart`
- Test: `test/features/galleries/domain/gallery_saved_filter_config_test.dart`

- [ ] **Step 1: Run the targeted preset test suite**

Run: `rtk flutter test test/core/presentation/widgets/saved_filter_dialog_test.dart test/core/data/repositories/graphql_saved_filter_repository_test.dart test/core/domain/entities/saved_filter_config_test.dart test/features/scenes/presentation/widgets/scene_saved_filter_dialog_test.dart test/features/scenes/data/repositories/graphql_scene_saved_filter_repository_test.dart test/features/scenes/domain/scene_saved_filter_config_test.dart test/features/performers/domain/performer_saved_filter_config_test.dart test/features/studios/domain/studio_saved_filter_config_test.dart test/features/tags/domain/tag_saved_filter_config_test.dart test/features/images/domain/image_saved_filter_config_test.dart test/features/galleries/domain/gallery_saved_filter_config_test.dart`
Expected: PASS

- [ ] **Step 2: Run a representative page/provider regression slice**

Run: `rtk flutter test test/features/images/presentation/providers/image_list_provider_test.dart test/features/scenes/presentation/providers/scene_list_provider_sort_test.dart`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add lib/core lib/features/performers lib/features/studios lib/features/tags lib/features/images lib/features/galleries lib/features/scenes test/core test/features
git commit -m "test: verify saved presets across entity pages"
```
