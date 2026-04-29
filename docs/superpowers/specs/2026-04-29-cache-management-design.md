# Cache Management Design Specification

## Overview
This document outlines the architecture and implementation strategy for adding cache cleaning and size management features to the StashFlow Flutter application. The system targets three primary storage hogs: image caches (thumbnails and full-size), temporary video buffers, and the local GraphQL database.

## 1. Architecture: `AppCacheService`
A centralized, Riverpod-managed service (`AppCacheService`) will be introduced to act as the single source of truth for cache operations.

### Responsibilities
- **Size Calculation:** Asynchronously compute the disk space used by different cache categories in megabytes (MB).
- **Cache Clearing:** Expose methods to clear specific cache categories or all caches simultaneously.
- **Size Enforcement:** Enforce user-defined size limits by pruning older files when thresholds are exceeded.

### Targeted Cache Mechanisms
1. **Images:**
   - **Thumbnails/Grid:** Managed by `flutter_cache_manager` (used in `StashImage`).
   - **Full-Size:** Managed by `extended_image` (used in `image_fullscreen_page.dart`). Both must be cleared when "Clear Image Cache" is triggered.
2. **Videos:**
   - Temporary buffer files created by `media_kit` in the system's temporary directory. The service will identify and delete these files based on their extensions or paths.
3. **Database:**
   - The `graphql_flutter` HiveStore database. Clearing this will wipe the stored GraphQL responses, forcing fresh network requests on the next load.

## 2. Configuration & Preferences
New settings will be added to the existing preferences system (`shared_preferences_provider.dart`):

- **`max_image_cache_size_mb`**: Defines the maximum allowed size for image caches.
  - Options: 100 MB, 500 MB, 1 GB, Unlimited.
- **`max_video_cache_size_mb`**: Defines the maximum allowed size for video temporary files.
  - Options: 500 MB, 1 GB, 2 GB, Unlimited.

*Enforcement:* The `AppCacheService` will check these limits (e.g., on app startup or periodically) and prune files (oldest first) if the calculated size exceeds the selected limit.

## 3. UI/UX: `StorageSettingsPage`
A new dedicated settings page will be added to provide visibility and control to the user.

- **Location:** Accessible via `SettingsHubPage` under a new "Storage & Cache" section.
- **Visuals:** 
  - A summary card or list displaying the current calculated size for Images, Videos, and the Database.
- **Controls:**
  - Individual "Clear" buttons for each category.
  - A global "Clear All Caches" button.
  - Dropdown menus to select the `max_image_cache_size_mb` and `max_video_cache_size_mb` preferences.

## 4. Testing & Error Handling
- **Concurrency:** Ensure size calculations and clearing operations run asynchronously to avoid blocking the UI thread.
- **File System Locks:** Handle potential `FileSystemException` gracefully if a file is currently in use (e.g., a video currently playing) when a clear operation is triggered.
- **State Updates:** Ensure the UI (sizes displayed) automatically refreshes after a clear operation or when limits are changed, utilizing Riverpod's reactive state.

## 5. Scope & Constraints
- The design specifically addresses local caching on the device. It does not affect data stored on the remote Stash server.
- Database cache limits are managed purely by manual clearing, as enforcing strict MB limits on the Hive database is complex and error-prone; limits apply strictly to media files.
