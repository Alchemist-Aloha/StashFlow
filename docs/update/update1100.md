# Update v1.10.0 (Nightly)

This update focuses on significant interface flexibility, performance optimizations, and enhanced multi-platform support.

## 🚀 New Features

### 📐 Dynamic Grid Customization
- **Configurable Column Counts:** You can now manually set the number of grid columns for:
  - **Scenes List**
  - **Performers List**
  - **Galleries List**
  - **Tags & Studios Lists**
  - **Image Waterfall (Masonry) Layout**
- **Responsive "Default" Mode:** By default, the app uses a smart responsive layout tailored to your device, but user-defined overrides now take precedence.
- **Settings Path:** Find these in **Settings > Interface Settings**.

### ⚡ Performance & Prefetching
- **Intelligent Scroll Prefetch:** The app now dynamically calculates how many items to preload based on your grid density. It ensures at least **two full screens** of content are warmed up ahead of your scroll position.
- **Dynamic Page Sizes:** Data fetching is now synced with your grid configuration. If you set a high-density grid, the app automatically increases the number of items fetched per page to ensure a seamless scrolling experience.
- **Enhanced Concurrency:** Increased background image prefetching concurrency to handle dense media grids without lag.

### ⌨️ Advanced Interaction (Desktop & Web)
- **Keybind Settings Page:** A new dedicated settings page to view and customize keyboard shortcuts.
- **New Keybind Actions:** Added support for image navigation (Previous/Next) and "Back" functionality via keyboard.
- **Custom Player Transitions:** Implemented smoother, custom transitions for entering and exiting scene details.

### 🔐 Authentication & Web Compatibility
- **Enhanced Web Support:** Significantly improved session management and cookie handling for the Web platform.
- **Password Authentication:** Refined login logic to prioritize password-based authentication, with improved reliability for persistent sessions.
- **GraphQL HTTP Factory:** Modernized client factory for better handling of platform-specific IO and Web networking requirements.

### 🎬 Video Player Improvements
- **Playback Speed Controls:** Directly adjust playback speed within the video player UI.
- **Enhanced UI Overlays:** Improved scrubbing functionality and clearer overlay feedback during playback.
- **Sprite Image (Thumbnail Atlas) Support:** Detects and utilizes sprite metadata for ultra-fast seek previews and more compact gallery thumbnails.

### 🛠️ Developer & Admin Tools
- **Developer Settings Page:** Integrated advanced diagnostic tools and logs into the Settings Hub.
- **Cleaned GraphQL Schema:** Removed deprecated types and unused queries to streamline networking and reduce app bundle size.

## 🔧 Fixes & Refinements
- **UI/UX:** Added missing tooltips to visibility toggle icons in server settings.
- **Stability:** Handled `DioException` during login more gracefully with better user feedback.
- **Networking:** Replaced `PersistCookieJar` with a more efficient `CookieJar` implementation.
- **Android:** Fixed issues with the rolling nightly build pipeline to ensure reliable APK delivery.
- **Linux:** Optimized performer matching loops in the repository layer for better performance on low-power devices.
- **Schema:** Massive cleanup of unused GraphQL definitions for a tighter, more robust codebase.

---
*For the latest updates and multi-platform builds, check the [Nightly Release Page](https://github.com/Alchemist-Aloha/StashFlow/releases/tag/nightly).*
