# StashFlow v1.26.0

## ✨ New Features

### App Configuration Backup

- Added a configuration backup/restore system allowing you to export and import all user-facing settings and server profiles.
- Backups can optionally include credentials (API keys, passwords, cookie headers, app lock passcode) — shown with a plaintext warning before export.
- Import replaces all current settings and profiles; a restart is recommended after import.
- New settings UI under Storage → App configuration with Save and Import actions.
- Supported by a versioned codec, document-based file storage, and a settings registry that maps every managed key for round-trip fidelity.

### Keyboard Shortcuts — Extended

- Added keyboard shortcuts for global navigation: **Next Tab**, **Previous Tab**, and direct **Tab {number}** selection.
- Added image viewer shortcuts: **First Image**, **Last Image**, **Close Image Viewer**.
- Added **Unbind** button per shortcut for quick removal.
- Added **reset confirmation dialog** to prevent accidental loss of custom bindings.
- Shortcuts are now grouped by context (**Global Navigation**, **Video Player**, **Image Viewer**) with section headers.
- Conflict detection: when binding a shortcut that is already assigned, the displaced action is shown via snackbar.
- Reserved system shortcuts (browser/OS) are now identified and blocked.
- Keybind settings page is now scrollable, supporting many more shortcuts without overflow.

### Scene Performer Age

- Performer birthdates are now loaded with scene data via GraphQL.
- Scene details display each performer's age in the scene's calendar year next to their name.
- Invalid or future birthdates are silently omitted.
- New `ScenePerformerTitle` widget renders the performer name with a muted age label.

### Scene Deduplication — Pagination & Compact Layout

- Scene deduplication results are now paginated, with configurable page size.
- Configuration controls (distance, duration difference, page size) are collapsed by default in a compact panel.
- Added a **Refresh** button in the app bar to re-run deduplication.
- Dropdown menus replace basic text controls for a cleaner look.

### Scene Tagger — Pagination

- Scene tagging now supports paginated loading for large scene lists.
- Underlying `findScenesPage` method returns both scenes and total count for accurate page-aware UIs.

## 🎨 UI & UX Improvements

- **Settings hub**: `SettingsPanelGroup` now supports disabling dividers between items; applied to settings hub for a cleaner look.
- **Scene details**: action padding balanced and compact metadata reveal action.
- **Image fullscreen page**: updated layout and interaction patterns.

## 🛡️ Playback & Stability

### Robust Desktop Fullscreen

- New `DesktopFullscreen` singleton provides serialized `enter()`/`exit()` transitions, preventing race conditions.
- **Windows**: Fullscreen now properly handles maximized windows — saves normal bounds, unmaximizes, enters fullscreen, and restores maximized state on exit.
- Windows borderless fullscreen controlled natively via `window_manager`.
- Fullscreen exit reliably restores the previous window state (maximized or normal).
- Polling-based state verification ensures transitions complete before subsequent operations.

### Android Media Notification

- Notification artwork races fixed: session-scoped temp file retention prevents deletion-while-reading by the native media service.
- Generation tracking ensures stale artwork fetches are discarded.
- Seek callback routes through the player state for proper position synchronization.
- Notification stop action removed as it conflicted with expected lifecycle behavior.

### Stream Resolver Simplified

- Removed MIME-type-based stream scoring, caching, and GraphQL-backed stream enumeration.
- The resolver now returns the scene's direct file stream directly, eliminating complexity and stale-cache bugs.
- Removed the `preferStreams` playback setting and its associated ARB keys.

### Background Playback & PiP

- Background playback policy enforced (continues playback when app is backgrounded).
- Picture-in-Picture (PiP) support integrated for Android.

## 🔧 Platform & Build Updates

### Android

- **Java**: 17 → 21 (`sourceCompatibility`, `targetCompatibility`, Kotlin `jvmTarget`).
- **AGP**: 8.11.1 → 9.3.0.
- **Kotlin**: 2.2.20 → 2.4.0.
- Removed `WRITE_EXTERNAL_STORAGE` permission (no longer needed on modern Android).
- Removed `resConfigs("en")` — all locales are now bundled.
- Removed `requestLegacyExternalStorage` flag.

### Windows

- Fullscreen now uses `window_manager` exclusively for state management (no raw Win32 API fallbacks).
- Maximized-to-fullscreen transitions preserve and restore window bounds correctly.
- ccache enabled for native C++ builds with MSVC debug-format fix (`/Z7` instead of `/Zi`).

### Linux

- App icon now resolved relative to the executable path (`/proc/self/exe`) instead of a hardcoded `data/` directory.

### macOS

- Added `com.apple.security.files.user-selected.read-write` entitlement for both Debug and Release profiles.

### Dependencies

- `audio_service`: 0.18.18 → 0.18.19
- `window_manager`: 0.5.1 → 0.5.2
- `screen_retriever`: 0.2.1 → 0.2.2
- `dio`: 5.9.2 → 5.10.0
- `extended_image`: 10.0.1 → 10.1.0
- Added `file_selector` and `share_plus` for config backup file operations.
- Removed `screen_brightness_android` version override (no longer needed with AGP 9).

## 🌍 Localization

- Added keyboard shortcut section labels (`global_section`, `video_section`, `image_section`).
- Added navigation shortcut labels: `next_tab`, `previous_tab`, `tab_{number}`.
- Added image viewer shortcut labels: `first_image`, `last_image`, `close_image`.
- Added `unbind` action label and reset confirmation dialog strings.
- Added `reserved` and `tab_reserved` conflict messages.
- Added `conflict_moved` template for displaced shortcut notifications.
- Added config backup UI strings: `config_backup_title`, `config_export`, `config_import`, `include_credentials`, `credentials_warning`, `exported`, `import_title`, `import_summary`, `import_confirm`, `imported`, `invalid`, `plaintext_label`.
- All new keys added to `app_en.arb`; translation gaps recorded in `l10n_untranslated.json`.

## 🧪 Testing

- Added `desktop_fullscreen_test.dart` covering enter/exit, maximized restore, error recovery, and serialized transitions.
- Added `app_config_backup_codec_test.dart`, `app_config_service_test.dart`, and `app_config_settings_registry_test.dart` for the full backup round-trip.
- Added `keybinds_provider_test.dart` covering bind/unbind/reset and conflict detection.
- Added `keybind_settings_page_test.dart` for the redesigned settings page.
- Added `scene_performer_title_test.dart` for age calculation and rendering.
- Added `playend_behavior_test.dart` for playback completion edge cases.
- Added `graphql_scene_repository_test.dart` and `stream_resolver_test.dart` for simplified resolver and paginated scene fetching.
- Added `media_handler_test.dart` for notification artwork lifecycle.
- Added `fullscreen_controller_test.dart` for fullscreen state management.
- Added `scene_deduplication_test.dart` and expanded `scene_tagger_test.dart`.
- Added `android_release_config_test.dart` to verify build configuration.
- Added `icon_path_test.cc` for Linux icon resolution.
- Updated `image_fullscreen_page_test.dart`, `scene_video_player_test.dart`, `video_player_ui_test.dart`, `video_playback_test.dart`, `keyboard_navigation_test.dart`, `fullscreen_mode_test.dart`, and `playback_settings_page_test.dart`.
