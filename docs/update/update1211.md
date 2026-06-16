# StashFlow v1.21.1

## ✨ New Features

*   **Star History**: Added a Star History section to the [README.md](../../README.md) tracking project growth over time.
*   **Android Settings Permission**: Requested the `WRITE_SETTINGS` permission in [AndroidManifest.xml](../../android/app/src/main/AndroidManifest.xml) files to allow setting-related modifications.

## 🎨 UI & UX Improvements

*   **Library Stats Feedback**: Wrapped the library stats entry point in [list_page_scaffold.dart](../../lib/core/presentation/widgets/list_page_scaffold.dart) with a proper tooltip (`stats_library_stats_tooltip`) and an `InkWell` layout to provide clean touch/press feedback.
*   **Playback Speed Semantics**: Enhanced the video playback speed control button in [video_playback_controls.dart](../../lib/features/scenes/presentation/widgets/video_controls/video_playback_controls.dart) with accessibility semantic labels and a tooltip.
*   **Scene Preview & Key Management**: Re-structured scene preview components in [scene_tagger_page.dart](../../lib/features/scenes/presentation/pages/scene_tagger_page.dart) to improve key management (`ValueKey('scene_preview_player_${scene.id}')`), preventing unnecessary widget recreations, improving thumbnail loading, and fixing caching issues.
*   **Deduplication Controls Layout**: Refactored the top control actions in [scene_deduplication_page.dart](../../lib/features/scenes/presentation/pages/scene_deduplication_page.dart) from a wrapping layout to a horizontal scrollable single-row `ListView`, optimizing button styling to scale gracefully between compact and regular modes.

## 🛠 Under the Hood

*   **Dependency Update**: Bumped `sqflite_common` from `2.5.9` to `2.5.11` in [pubspec.lock](../../pubspec.lock).
*   **Manifest Namespaces**: Cleanly added the tools namespace (`xmlns:tools="http://schemas.android.com/tools"`) to [AndroidManifest.xml](../../android/app/src/main/AndroidManifest.xml) files to support permission ignores (`tools:ignore="ProtectedPermissions"`).
*   **Test Expansion**: Added localized test scenarios for preset dialog errors, Chinese translation verification on deduplication/tagger pages, and adjusted layout tests for the new scrollable control structures.

## 🌍 Localization

*   **Comprehensive i18n Refactoring**: Removed hardcoded text strings in [saved_filter_dialog.dart](../../lib/core/presentation/widgets/saved_filter_dialog.dart), [scene_deduplication_page.dart](../../lib/features/scenes/presentation/pages/scene_deduplication_page.dart), [scene_tagger_page.dart](../../lib/features/scenes/presentation/pages/scene_tagger_page.dart), [scenes_page.dart](../../lib/features/scenes/presentation/pages/scenes_page.dart), [tools_page.dart](../../lib/features/tools/presentation/pages/tools_page.dart), and [settings_hub_page.dart](../../lib/features/setup/presentation/pages/settings/settings_hub_page.dart), converting them to use `context.l10n`.
*   **Expanded Translations**: Refreshed and populated new localizations across German, English, Spanish, French, Italian, Japanese, Korean, Russian, and Chinese within [apply_translations.py](../../scripts/apply_translations.py) and the corresponding generated `.arb` / `.dart` localizations.
*   **Language Fixes**: Standardized Simplified Chinese settings translations (e.g., updating `common_set` to `设置`) and polished grammar patterns across deduplication messages.
