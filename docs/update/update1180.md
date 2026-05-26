# Update 1.18.0

## UI & User Experience

- **Gallery Ratings & Details:**
  - Added an optional details widget to the rating bottom sheet for an improved user experience.
  - Added long press functionality to `GalleryCard` to easily open the rating and details display.
- **Media Navigation:**
  - Added scrollbars to media, gallery, and scene strips for improved horizontal navigation.
  - Optimized scroll prefetching in horizontal lists by checking the last visible index to avoid redundant loop iterations.
- **Video Controls & Layout:**
  - Refined video controls layout with compact mode adjustments and improved overall styling.
  - Enhanced video controls with time display elements.
  - Updated video control button sizes and spacing for better usability.

## Playback & Fullscreen Management

- **Playback Queue:**
  - Implemented playback queue management across scenes and studios, significantly enhancing navigation and scene transitions.
- **Playback Session Management:**
  - Added `PlaybackSessionController` for managing playback sessions and stream bindings.
  - Implemented `PlaybackActivityTracker` for managing playback activity and scene details.
- **Player Settings:**
  - Introduced `PlayerSettings` and `PlayerSettingsStore` for managing playback preferences.
  - Added resume playback position feature with localization support.
  - Extracted `PlayerSurface` for shared and more maintainable video rendering.
- **Fullscreen Logic:**
  - Implemented comprehensive fullscreen management with `FullscreenController` and updated `PlayerViewMode` handling.
  - Enhanced fullscreen toggle logic to ensure correct scene playback and fixed toggle issues in scene details.
  - Enhanced scene navigation by adding the `extra` parameter to `context.push`.

## Network & Security

- **App Transport Security & Sandboxing:**
  - Added App Transport Security (ATS) settings and updated entitlements for network access.
  - Added network client entitlement for macOS app sandboxing.
- **Authentication & Storage:**
  - Added cookie header handling to profile credentials management.
  - Enhanced profile update logic to handle authentication modes and credentials.
  - Refactored secure storage implementation to enhance data handling and error management.

## Architecture & Under-the-hood

- **GraphQL & Performance:**
  - Refactored GraphQL repositories to use `BaseRepository` for standardized error handling.
  - Optimized stream prewarming and cleaned up unused code in the video player.
- **Debugging & App Initialization:**
  - Added debug logging features with localization support and configuration options.
  - Implemented deferred startup checks and optimized overlay initialization.
- **Accessibility:**
  - Added `excludeFromSemantics` to `ImageFullscreenPage` for improved screen reader experiences.
- **Localization:**
  - Replaced hardcoded strings with localization keys throughout the app.

## Documentation & Testing

- **Documentation Updates:**
  - Added detailed issue documentation for various components including backend, core, entity browsing, images, navigation, scenes, setup, and tests.
  - Updated README to clarify testing platforms and encourage community feedback.
- **Testing & CI Improvements:**
  - Updated widget tests to ensure proper rendering and state management.
  - Removed unused video file creation in the enforceVideoCacheLimit test.
  - Improved macOS CI build stability by addressing `connectivity_plus` dependency issues.
