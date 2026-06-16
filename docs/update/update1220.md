# StashFlow v1.22.0

## ✨ New Features

*   **Mini Player Video**: The mini player can now play the actual scene video instead of showing just metadata. Added a new toggle in Interface Settings to control this behavior, configurable via [interface_settings_page.dart](../../lib/features/settings/presentation/pages/settings/interface_settings_page.dart). 
*   **Video Controls Visibility**: Added a `showControls` option in [native_video_controls.dart](../../lib/features/scenes/presentation/widgets/native_video_controls.dart) to programmatically manage the visibility of video controls overlay.
*   **Cast Session Improvements**: Cast sessions now properly restart media when switching scenes, with improved session handling in [cast_service.dart](../../lib/core/data/services/cast_service.dart).
*   **Playback Startup Recovery**: Implemented playback startup recovery with retry logic and slow-startup handling in [playback_session_controller.dart](../../lib/features/scenes/presentation/providers/playback_session_controller.dart) for more resilient playback initialization.
*   **Viewport-Based Image Prefetching**: Images are now prefetched based on viewport visibility in [scene_card.dart](../../lib/features/scenes/presentation/widgets/scene_card.dart), with optimized cache behavior for smoother browsing.
*   **Interaction-Driven VTT Loading**: VTT subtitle files are now loaded on demand (triggered by user interaction) in [vtt_service.dart](../../lib/core/utils/vtt_service.dart), with deduplication of concurrent requests.
*   **Multi-Value Criteria Normalization**: Server payload normalization for multi-value criteria in [graphql_scene_repository.dart](../../lib/features/scenes/data/repositories/graphql_scene_repository.dart) for duplicate scene detection and other queries.

## 🎨 UI & UX Improvements

*   **Material Style Filter Panels**: Replaced `Container` with `Material` across all entity filter panels ([scene_filter_panel.dart](../../lib/features/scenes/presentation/widgets/scene_filter_panel.dart), [image_filter_panel.dart](../../lib/features/images/presentation/widgets/image_filter_panel.dart), [gallery_filter_panel.dart](../../lib/features/galleries/presentation/widgets/gallery_filter_panel.dart), [performer_filter_panel.dart](../../lib/features/performers/presentation/widgets/performer_filter_panel.dart), [studio_filter_panel.dart](../../lib/features/studios/presentation/widgets/studio_filter_panel.dart), [tag_filter_panel.dart](../../lib/features/tags/presentation/widgets/tag_filter_panel.dart)) for improved visual styling and consistency.
*   **Gallery & Tag List Tuples**: Refactored [list_page_scaffold.dart](../../lib/core/presentation/widgets/list_page_scaffold.dart) to use `AsyncValue.preserve` for list tuples, replacing the intermediate `GalleryTuple`/`TagTuple` layers, fixing `AsyncValue.when` count mismatches, and ensuring null-safety for scene tag lists.
*   **Scene Card Refactoring**: Streamlined [scene_card.dart](../../lib/features/scenes/presentation/widgets/scene_card.dart) by removing `StashImage` overlays in favor of viewport-aware `CachedNetworkImage`, eliminating redundant `loaded` state tracking and unused preload logic.

## 🛠 Under the Hood

*   **Duplicate Scenes Query Fix**: Fixed the `size` field type from `String` to `int` in the `FindDuplicateScenes` GraphQL query within [scenes.graphql.dart](../../lib/features/scenes/data/graphql/scenes.graphql.dart).
*   **Dependency Compatibility**: Updated `screen_brightness` package versions and added Gradle-level overrides in [build.gradle.kts](../../android/build.gradle.kts) and ProGuard keep rules in [proguard-rules.pro](../../android/app/proguard-rules.pro) for Android build compatibility.
*   **Build Configuration**: Added `android:usesCleartextTraffic="true"` and `android:requestLegacyExternalStorage="true"` flags to `AndroidManifest.xml`, and added the `tools` XML namespace declaration.
*   **Locale Refinement**: Narrowed supported locales in `app_localizations` to exclude generic `zh` and use script-specific `zh_Hans`/`zh_Hant` variants, with corresponding `.arb` and `.dart` updates.
*   **Test Expansion**: Added test coverage for cast service, VTT service, playback session controller, player settings, interface settings page, scene card, scene video player, and list page scaffold behaviors.

## 🌍 Localization

*   **New Localizations**: Added two new localization keys (`miniplayer_use_actual_video`, `miniplayer_use_actual_video_subtitle`) across all supported languages (de, en, es, fr, it, ja, ko, ru, zh_Hans, zh_Hant) for the new mini player video setting.
*   **Translation Cleanup**: Removed the generic `zh` locale in favor of script-specific `zh_Hans` and `zh_Hant` for proper Simplified/Traditional Chinese separation.
