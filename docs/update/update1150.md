**Update 1.15.0**

**Release Summary**

- **Scope**: Major migration to the MediaKit video engine, implementation of advanced video controls and gestures, new cache management system, enhanced casting support, and significant UI/UX improvements in video playback.

**Highlights**

- **MediaKit Video Engine Migration**: Completely refactored the video player integration to use `media_kit`. This migration provides significantly better performance, broader codec support, and a more stable playback experience.
- **Advanced Video Controls & Gestures**:
  - **Side-swipes**: Introduced intuitive side-swipe gestures for controlling volume and brightness directly on the video player.
  - **Improved Controls Layout**: Redesigned video controls with better spacing, refined button sizes, and a more consistent aesthetic.
  - **Speed Control Enhancements**: The speed widget now includes 0.25x and 0.5x options, a slider for precise adjustment, and a one-tap reset to 1x.
- **Casting (DLNA/Chromecast)**: Migrated to `dart_cast` for more reliable device discovery and playback control. Casting is now fully integrated into the native video controls UI.
- **Cache & Storage Management**: Added a new Storage Settings page where users can monitor cache sizes and clear application cache with a single tap.
- **Stream Prewarming**: Implemented a sophisticated prewarming mechanism that starts downloading the next video's data before playback begins, ensuring near-instant transitions between scenes.
- **TikTok Mode Enhancements**: Improved auto-scroll behavior at the end of videos and added trackpad support for scrolling through the TikTok-style feed.
- **Subtitle Improvements**: Enhanced subtitle rendering and management, including better handling of external subtitle streams.

**Notable Fixes**

- Improved trackpad scroll detection for refreshing lists in `ListPageScaffold`.
- Refined video loading and buffering states for a smoother UI response.
- Standardized UI elements (padding, alignment, button sizes) across all video control layouts.
- Fixed various lint warnings and migrated away from deprecated APIs.

**Internal / Developer Changes**

- Introduced `AppVideoController` as a unified wrapper for video operations.
- Implemented `AppCacheService` and `cacheSizesProvider` for centralized storage management.
- Added `ProfileCredentialsProvider` for more robust authentication handling.
- Optimized network requests by increasing the default Byte-Range for prewarming (2MB) and video headers (10MB).
- Added comprehensive design specifications and implementation plans for cache management and video engine migration.

**Files changed (key items)**

- **Video Playback:** `lib/features/scenes/` (Migration to MediaKit, gesture implementation, UI refactor)
- **Settings:** `lib/features/setup/presentation/pages/settings/storage_settings_page.dart` (New cache management UI)
- **Casting:** `lib/core/data/services/cast_service.dart` (Migration to `dart_cast`)
- **Core Services:** `lib/core/data/cache/app_cache_service.dart` (New cache service)
- **Documentation:** `docs/` (Cache management specs, video engine migration plans)
