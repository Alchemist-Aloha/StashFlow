# Update v1.12.0

This release focuses on a revolutionary video playback experience, introducing advanced gesture controls, specialized mobile optimizations for vertical content, and significant architectural modernizations.

## 🚀 New Features Since v1.11.0

### 🎬 Transformable Video Surface
- **Pinch-to-Zoom & Pan:** Introduced the `TransformableVideoSurface`, allowing users to zoom into any part of a video and pan around the frame during playback.
- **Free Rotation:** Added support for arbitrary video rotation via gestures, perfect for viewing content captured at non-standard angles.
- **Enhanced Fitting Logic:** Refactored the internal rendering pipeline to support flexible fitting modes, including a new "Forced Fill" mode for vertical content.
- **Integration:** Seamlessly integrated the transformable surface into both the standard inline player and the dedicated fullscreen page.

### 📱 Vertical Content & Mobile Optimization
- **Square Video Reframing:** Automatically overrides square (1:1) video aspect ratios to a 9:16 portrait format on mobile devices. This prevents the "fat" look of square content and matches the aesthetic of modern vertical feeds.
- **Intelligent Stretching:** Implemented `BoxFit.fill` logic for forced-ratio content, stretching the video canvas to perfectly fill portrait containers on mobile while maintaining original proportions on Desktop/Web.
- **Adaptive Scene Cards:** Updated grid and list cards to respect the new portrait overrides for square media, ensuring visual consistency across the library.

### 🎵 Enhanced TikTok Discovery Feed
- **Intuitive Controls:** Replaced the thin progress line with a thicker, more accessible progress slider featuring a round thumb indicator for precise seeking.
- **Clean UI:** Removed the semi-transparent gray backgrounds from action buttons (Star, Fullscreen, Info) to provide a more immersive, unobstructed viewing experience.
- **Smart Titles:** Untitled scenes now automatically display their cleaned filestem (e.g., "Great Scene") instead of generic "Scene [ID]" labels, mirroring the detail page logic.
- **Immersive Fitting:** Optimized the feed to use edge-to-edge fitting for portrait content while maintaining letterboxing only for wide landscape videos.

### ⌨️ Desktop Power User Features
- **Tab Navigation:** Added native keyboard shortcuts for switching between main navigation tabs (Home, Scenes, Images, etc.) on Windows, Linux, and macOS.
- **Shortcut Discovery:** Integrated these shortcuts into the system-wide keybindings documentation.

### 🔐 Authentication & Connectivity
- **Basic Auth Support:** Expanded the URL resolver to support Basic Authentication, improving compatibility with a wider range of Stash server configurations.
- **Unified Headers:** Further refined the exclusive priority authentication system, ensuring `StashImage` and `VideoPlayer` handle credentials with maximum security.

## 🔧 Fixes & Refinements Since v1.11.0

### Core Architecture
- **Freezed Migration:** Continued the modernization of the domain layer by migrating criterion models and core entities to use `freezed` for immutable state management and robust JSON serialization.
- **Shared Scraped Entities:** Unified the structure for scraped metadata (Scenes, Performers, etc.) into a shared core directory to reduce duplication and improve maintainability.
- **Service Imports:** Fixed several missing imports in native video controls and utility files that were impacting release builds.

### Web & Platform Compatibility
- **Auth Resilience:** Resolved issues where thumbnails would fail to load on Web when utilizing API key authentication.
- **Target Platform Logic:** Standardized `defaultTargetPlatform` checks across UI components to ensure platform-specific features (like aspect ratio overrides) only trigger on the intended devices.
- **Tree-Shaking:** Optimized build configurations to better handle icon tree-shaking, reducing final binary sizes.

### Reliability & Performance
- **Transformation Persistence:** Improved the `TransformationNotifier` to maintain zoom and rotation states reliably during orientation changes.
- **Build Runner:** Optimized the code generation process to be more selective, reducing total build times.

### Automated Testing
- **Surface Verification:** Added a new test suite for `TransformableVideoSurface` to verify gesture math and matrix transformations.
- **Layout Testing:** Updated widget tests for `TiktokScenesView` and `SceneVideoPlayer` to validate the new aspect ratio and fitting logic.

---
For the latest updates and platform-specific artifacts, see the [Release Page](https://github.com/Alchemist-Aloha/StashFlow/releases).
