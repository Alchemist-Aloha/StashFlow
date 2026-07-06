# StashFlow v1.24.0

## ♻️ Architecture & Code Refactoring

### Entity Media Grid Consolidation

Per-entity media and gallery grid pages have been consolidated into shared components, eliminating code duplication across performers, studios, tags, and groups.

- **14 per-entity pages deleted**: `performer_media_grid_page`, `performer_galleries_grid_page`, `studio_media_grid_page`, `studio_galleries_grid_page`, `tag_media_grid_page`, `tag_galleries_grid_page`, `group_media_grid_page` and their corresponding providers.
- **4 shared files added**: [`entity_gallery_grid_page.dart`](../../lib/features/galleries/presentation/pages/entity_gallery_grid_page.dart), [`entity_media_grid_page.dart`](../../lib/features/scenes/presentation/pages/entity_media_grid_page.dart), [`entity_gallery_filter_scope.dart`](../../lib/features/galleries/presentation/providers/entity_gallery_filter_scope.dart), and [`entity_media_filter_scope.dart`](../../lib/features/scenes/presentation/providers/entity_media_filter_scope.dart) now serve all entity types through parameterized providers.

### Grid Layout & Column Settings — Enum Consolidation

Individual Riverpod providers for grid layouts and column counts have been replaced with enum-based family providers.

- **`GridLayoutSetting` enum** ([`layout_settings_provider.dart`](../../lib/core/presentation/providers/layout_settings_provider.dart)): Replaces 9 separate `*GridLayout` providers (`PerformerMediaGridLayout`, `PerformerGalleriesGridLayout`, `StudioMediaGridLayout`, etc.) with a single `gridLayoutSettingProvider` family.
- **`GridColumnSetting` enum**: Replaces 8 separate `*GridColumns` providers (`sceneGridColumnsProvider`, `galleryGridColumnsProvider`, `performerGridColumnsProvider`, etc.) with a single `gridColumnSettingProvider` family.
- Interface settings page updated to use the new enum-based APIs throughout.

### Shared List Providers

Entity-specific providers consolidated into reusable shared providers:

- **`ListScrollTarget` enum** + [`list_scroll_controller_provider.dart`](../../lib/core/presentation/providers/list_scroll_controller_provider.dart): Replaces per-entity scroll controller providers with a single `listScrollControllerProvider` family. Controllers are properly disposed via `ref.onDispose`.
- **[`list_random_seed_provider.dart`](../../lib/core/presentation/providers/list_random_seed_provider.dart)**: Replaces per-entity random seed providers with a single `listRandomSeedProvider` family keyed by entity type string.

### Saved Filter Refactoring

- **Repository layer simplified**: `graphql_scene_saved_filter_repository.dart` and `graphql_scene_marker_saved_filter_repository.dart` deleted; saved filter operations now go through the shared [`graphql_saved_filter_repository.dart`](../../lib/core/data/graphql/graphql_saved_filter_repository.dart).
- **Domain entities streamlined**: All per-entity saved filter configs (`SceneSavedFilterConfig`, `PerformerSavedFilterConfig`, `StudioSavedFilterConfig`, `TagSavedFilterConfig`, `GallerySavedFilterConfig`, `ImageSavedFilterConfig`, `SceneMarkerSavedFilterConfig`, `GroupSavedFilterConfig`) refactored to share logic through a common [`SavedFilterConfig`](../../lib/core/domain/entities/saved_filter_config.dart) base.
- **Dialog inlined**: `scene_marker_saved_filter_dialog.dart` inlined directly into the markers page, removing an unnecessary abstraction layer.

### BaseRepository → GraphQL Validator

The `BaseRepository` abstract class has been removed. Its validation logic (`validateResult`, `throwNormalized`) now lives as standalone functions in [`graphql_exception.dart`](../../lib/core/data/graphql/graphql_exception.dart), and 8 domain repository interface files (`gallery_repository.dart`, `group_repository.dart`, `image_repository.dart`, `performer_repository.dart`, `scene_repository.dart`, `scene_marker_repository.dart`, `studio_repository.dart`, `tag_repository.dart`) have been deleted.

### Dead Code Removal

- Removed `shimmer` placeholder widget ([`skeleton.dart`](../../lib/core/presentation/widgets/skeleton.dart)) and `status_views.dart`.
- Removed `clock` package dependency — all usages replaced with `DateTime.now()`.
- Removed `scene_saved_filter_delegates` and `scene_scrape_customization_provider`.

---

## ✨ New Features & Enhancements

### GraphQL Query Timeout

All GraphQL clients now enforce a **60-second request timeout** (`graphqlRequestTimeout`) to prevent hanging queries from blocking the UI indefinitely. Applied to `profileGraphqlClient`, the main `GraphqlClient` provider, and the fallback localhost client. Tests added in [`graphql_client_test.dart`](../../test/core/data/graphql/graphql_client_test.dart).

### Entity Picker Async Loading

The entity picker (used across scene/performer/tag/studio/gallery filters and edit pages) has been rebuilt with async loading:

- Replaced synchronous Riverpod `watch`-based loading with a `FutureBuilder` pattern for proper loading states and error handling.
- `_selectedEntities` changed from `List<T>` to `Map<String, T>` for O(1) lookups and correct deduplication.
- Added `CircularProgressIndicator` during loading and localized error messages on failure.
- Non-multi-select mode now clears previous selection automatically.
- Test coverage added in [`entity_picker_test.dart`](../../test/features/scenes/presentation/widgets/entity_picker_test.dart).

---

## ⚡ Performance

### Pagination Throttling

Scroll-based pagination triggers ([`list_page_scaffold.dart`](../../lib/core/presentation/widgets/list_page_scaffold.dart)) now include a **500ms debounce** (`_fetchThreshold`) in the `NotificationListener<ScrollNotification>`, preventing rapid-fire redundant data fetches when scrolling quickly through long lists.

---

## 🎨 Accessibility

- Replaced bare `GestureDetector` widgets with `Tooltip`, `Material`, and `InkWell` throughout the app for proper touch feedback and semantic labeling. Applies to studio links, filter panels, card interactions, and settings controls.
- Updated layout section titles with segmented keys for screen reader navigation.

---

## 🌍 Localization

- **21 new l10n keys** added across all 11 supported locales (DE, EN, ES, FR, IT, JA, KO, RU, ZH, ZH_Hans, ZH_Hant):
  - Filter/sort marker titles: `filter_markers_title`, `sort_markers_title`, `markers_title`, `markers_search_hint`
  - Metadata labels: `duration_title`, `dates_title`, `created_at_title`, `updated_at_title`, `scene_title`, `scene_date_title`, `scene_created_at_title`, `scene_updated_at_title`
  - State labels: `organized_title`, `interactive_title`, `scraped_metadata_title`, `local_scene_title`
  - Settings: `entity_layouts_title`, `entity_layouts_subtitle`, `groups_browsing_mode_subtitle`, `markers_browsing_mode_subtitle`
  - Stats: `stats_subtitle_0_gb`, `stats_subtitle_0_unique_items`
  - Misc: `tags_title`, `scenes_title`, `sub_group_count_title`, `marker_title`
- Chinese (zh/zh_Hans/zh_Hant) translations refined for readability.
- Regenerated all `app_localizations_*.dart` files.

---

## 🐛 Bug Fixes

- Fixed hardcoded strings across scene deduplication, tagger, filter panels, and tools pages — now all routed through `context.l10n` ([#264](../../pull/264), [#266](../../pull/266)).
- Fixed `package_info_plus` dependency to use caret syntax (`^10.1.0`) with an override pinning to `10.1.0` for stability.
- Fixed navigation and localization test failures caused by refactored providers.
- Fixed `entity_layouts_subtitle` translation clarity in Chinese.

---

## 🔧 Dependencies & Tooling

- **`clock`**: Removed — all usages replaced with `DateTime.now()`.
- **`package_info_plus`**: Version spec relaxed to `^10.1.0` (with `10.1.0` override).
- **`min_sdk_android`**: Raised from 21 to 24.
- **`graphql_codegen`**: Updated from 3.0.1 to 3.0.2.
- **`screen_retriever`**: Updated from 0.2.1 to 0.2.2 (includes Linux, macOS, Windows, and platform interface sub-packages).
- **`window_manager`**: Updated from 0.5.1 to 0.5.2.
- Test infrastructure updated: helpers refactored, tests migrated to use GraphQL repositories directly, formatting improved across the test suite.

---

## 🧪 Testing

- Added [`entity_picker_test.dart`](../../test/features/scenes/presentation/widgets/entity_picker_test.dart) covering async loading, selection mechanics, and performer selection scenarios.
- Added `SceneEditPage` test to verify existing tags are preserved when adding new tags.
- Expanded GraphQL client tests with timeout scenarios.
- Updated lifecycle, UI, and provider tests across all affected modules (220 test files touched).
