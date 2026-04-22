# Update v1.11.0

This release introduces major improvements to media organization, enhanced security with unified authentication, a more powerful search experience, and extensive UI refinements across the application.

## 🚀 New Features Since v1.10.0

### ⚡ Performance & Efficiency (Bolt)
- **Granular Rebuilds:** Refactored all major list pages to use `MediaQuery.sizeOf(context)`, isolating widgets from unrelated screen changes (like keyboard events) and significantly reducing redundant builds.
- **Scroll Optimization:** Hoisted invariant calculations and list allocations out of `itemBuilder` loops in Scenes and Images pages.
- **Complexity Reduction:** Reduced list lookup complexity from O(N) to O(1) during scrolling by pre-computing lookup maps for active data sets.
- **Deduplication:** Implemented synchronous task tracking to prevent redundant async operations during rapid widget rebuilds.

### 📁 Advanced Media Organization
- **Unified "Organized" Filter:** Introduced a new `OrganizedFilter` system across all media types (Scenes, Studios, Tags), allowing users to filter by "Organized", "Unorganized", or "Any".
- **Enhanced Sorting Options:** Expanded sorting capabilities for Studios and Tags, including:
  - Rating, Date Created, Updated At.
  - Scene/Image/Gallery counts.
  - Play Count and O-Counter (for relevant entities).
- **Hardened Filter Logic:** Refactored filter panels for better consistency and performance.

### 🔍 Search & Discovery
- **Search History:** Implemented persistent search history with **Material 3 SearchAnchor** in `ListPageScaffold`.
- **Auto-Submit:** Added auto-submission of search queries when the search bar is closed or the "Done" action is triggered.
- **Improved UX:** Full history display and clear-search functionality integrated into the unified header.

### 🔐 Security & Unified Authentication
- **Exclusive Priority Logic:** Implemented a robust authentication priority system: `Cookie > Bearer > Basic > ApiKey`. Only the highest-priority valid credential is sent to the server.
- **Unified Media Headers:** Verified that `StashImage` (thumbnails) and `VideoPlayer` (streams) consistently use these custom headers, improving compatibility with authenticated servers.
- **Web-Specific Fallback:** Optimized the `apikey` URL injection for web environments where custom headers might be restricted.
- **Enhanced Privacy:** Removed username and password from generated URLs in favor of header-based authentication where possible.
- **Proxy Auth Support:** Added a setting to enable/disable proxy authentication modes for advanced networking setups.

### 🎬 Scene Editing & Metadata
- **New Scraper UI:** Enhanced scraper functionality with improved URL handling and a new validation report UI.
- **Metadata Editing:** Significant updates to scene editing components, including improved input fields and status indicators.
- **Batch Tasks:** Improved reliability for background tasks like PHash generation and URL resolving.

### 🌍 Localization & Accessibility
- **Complete Localization Coverage:** Localized dozens of new strings across all supported languages, including new sorting options and filter modes.
- **Accessibility Sweep:** Added localized tooltips to `IconButton` components across the app, specifically targeting search history removal and query clearing in `ListPageScaffold`.
- **Semantic Labels:** Verified that all interactive elements map correctly to screen reader labels for better broad device support.

## 🔧 Fixes & Refinements Since v1.10.0

### UI/UX Stability
- **Responsive Layouts:** Refactored `SettingsPage` and other dense views using `Wrap` and `Expanded` to prevent overflows on small/narrow screens.
- **Grid Density:** Refined scene grid layouts with improved aspect ratios (`1.15`) and spacing for better metadata readability.
- **Consistency:** Replaced various `OutlinedButton` instances with `TextButton` for a more consistent visual style across the app.
- **Tablet Optimization:** Improved `NavigationRail` and adaptive grid behaviors for larger screen sizes.

### Reliability & Performance
- **Mock Data Handling:** Fixed a bug where mock repositories in tests would persist error states across retries; improved test helpers for more deterministic UI testing.
- **Video Playback:** Optimized stream prewarming and resolver logic to reduce first-frame latency.
- **Subtitle Resilience:** Improved robustness of subtitle loading, adding fallbacks for empty responses or malformed VTT data.
- **CI/CD:** Streamlined the nightly release workflow and optimized Gradle build configurations.

### Automated Testing
- **Search Testing:** Added comprehensive coverage for the new search submission and history logic.
- **Filter Verification:** Added unit and widget tests for the new `OrganizedFilter` logic.
- **Auth Verification:** Implemented a new suite of tests in `auth_headers_test.dart` to verify the exclusive priority system.

---
For the latest updates and platform-specific artifacts, see the [Release Page](https://github.com/Alchemist-Aloha/StashFlow/releases).
