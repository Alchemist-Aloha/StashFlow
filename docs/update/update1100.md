# Update v1.10.0 (Nightly)

This changelog covers everything merged since **v1.9.0**, with a focus on interface flexibility, playback improvements, localization, performance, and platform reliability.

## 🚀 New Features Since v1.9.0

### 📐 Interface & Layout Customization
- Added **dynamic grid column settings** for:
  - Scenes
  - Performers
  - Galleries
  - Tags
  - Studios
  - Image waterfall/masonry layout
- Improved responsive behavior so **Default mode remains adaptive**, while manual column overrides take priority.
- Added **main-pages gravity orientation setting** for non-fullscreen browsing pages.
- Added **fullscreen gravity orientation controls** for video playback, including aspect-ratio-aware orientation matching.

### ⚡ Performance & Scrolling
- Implemented **dynamic prefetch distance** tuned to active grid density.
- Added **dynamic page sizing** so data fetch size scales with layout density for smoother continuous scrolling.
- Increased prefetch efficiency and reduced runtime work by **hoisting expensive layout calculations** out of `itemBuilder` loops (including Images page paths).
- Improved media-grid smoothness with better high-density loading behavior.

### 🎬 Video Player & Playback
- Added **playback speed controls** in player UI.
- Improved playback controls and overlays, including better scrubbing UX.
- Added **sprite thumbnail atlas support** for fast seek previews.
- Added and wired **gravity-controlled fullscreen orientation** behavior with player state support.
- Refactored `NativeVideoControls` internals for maintainability while preserving behavior.

### ⌨️ Keyboard & Desktop Interaction
- Added a dedicated **Keybind Settings** page.
- Added new keybind actions for:
  - Previous image
  - Next image
  - Back navigation
- Improved keybind settings page layout and styling.

### 🔐 Authentication, Networking & Web Compatibility
- Introduced a **GraphQL HTTP client factory** for web and IO platform differences.
- Added and refined **password-based authentication** and made it the default mode.
- Improved web session handling and cookie behavior across login flows.
- Improved authentication state management and login reliability.

### 🌍 Localization & Language Support
- Added complete **l10n infrastructure** (`l10n.yaml`, delegates, templates, generated locales).
- Integrated localization delegates into app startup.
- Added broad translations across supported locales (including zh-Hans/zh-Hant handling improvements).
- Localized navigation labels, settings sections, scene editing/status/error strings, subtitle settings, and common UI actions.
- Added **App Language override** in interface settings.

### 🛠️ Developer & Admin Tooling
- Added **Developer Settings** page and surfaced advanced diagnostic/log utilities in settings hub.
- Performed significant **GraphQL schema cleanup**, removing deprecated/unused definitions.

## 🔧 Fixes & Refinements Since v1.9.0

### UI/UX Fixes
- Added missing tooltips for visibility toggles in server settings.
- Improved transitions and navigation feel for scene details/player routes.
- Refined scene details layout decomposition for readability and long-term maintainability.

### Stability & Error Handling
- Improved login error handling for `DioException` with clearer failure behavior.
- Resolved analyzer/test issues and cleanup warnings.

### Networking & Session Reliability
- Replaced `PersistCookieJar` with `CookieJar` for simpler and more reliable cookie management.
- Removed stale/unused authentication flags and streamlined session flow.

### Build, CI & Release Pipeline
- Updated nightly workflow artifact handling and simplified release steps.
- Adjusted build command defaults in `build.ps1` (removed unnecessary release flags for web/platform builds).
- Fixed/iterated nightly trigger behavior and delivery pipeline reliability.

### Platform-Specific Improvements
- Linux repository-side loop optimization for performer matching.
- General web compatibility improvements around auth/session networking.

---
For the latest nightly updates and cross-platform artifacts, see the [Nightly Release Page](https://github.com/Alchemist-Aloha/StashFlow/releases/tag/nightly).
