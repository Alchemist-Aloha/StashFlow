**Update 1.16.0**

**Release Summary**

- **Scope**: Enhanced interaction features, improved media downloading/saving capabilities, significant performance optimizations, and comprehensive localization updates across multiple languages.

**Highlights**

- **Enhanced Interaction & Personalization**:
  - **Favorite Buttons**: Added favorite toggle buttons to the Studio and Tag details pages, matching the existing Performer functionality. This allows for quick organization and filtering of your favorite content creators and categories.
- **Media Downloading & Saving**:
  - **Direct Save to Gallery**: Implemented the ability to save images and videos directly to the device's native gallery/photo library using the `gal` package.
  - **Improved Download UX**: Added dedicated download buttons to the image viewer and scene details page, with specific support for Android, iOS, and macOS.
  - **Enhanced File Handling**: Improved file extension detection and metadata handling when saving media to ensure compatibility with local galleries.
- **Performance Optimizations (Bolt & Palette)**:
  - **Bolt [Performance]**: Hoisted invariant layout calculations and context lookups out of scroll listeners to prevent redundant processing during list scrolling.
  - **Palette [Accessibility]**: Added tooltips to floating action buttons and icon buttons throughout the app for better accessibility and user feedback.
  - **RepaintBoundary**: Strategically added `RepaintBoundary` to complex image widgets to reduce redundant painting and improve scrolling smoothness.
  - **GraphQL Optimization**: Refined the `VideoPlayerProvider` to optimize media handler updates and track switching, reducing overhead during playback.
- **UI/UX Refinements**:
  - **Navigation Enhancement**: Improved keyboard navigation UX in the server profile drawer.
  - **Refined Feedback**: Enhanced the visual feedback and accessibility of the scene rating star system.
  - **ShellPage Refactor**: Improved code formatting and readability in the main navigation shell.
- **Localization & Internationalization**:
  - **Comprehensive Translations**: Major updates to German (de), Spanish (es), French (fr), Italian (it), Japanese (ja), Korean (ko), Russian (ru), and Chinese (zh) localization files.
  - **String Externalization**: Continued efforts to replace hardcoded text with l10n strings across the entire codebase.

**Notable Fixes**

- **macOS Support**: Fixed several build issues on macOS, including setting the deployment target to 11.0 and configuring necessary photo library permissions.
- **Stream Prewarmer**: Enhanced the prewarmer to handle `HttpClient` more safely, especially for web platforms, and ensured proper resource cleanup.
- **Scene Details**: Improved video download handling for Linux and fixed layout issues in the scene details view.
- **Version Management**: Standardized versioning across `pubspec.yaml` and the README.

**Internal / Developer Changes**

- **New Dependencies**: Added the `gal` package for native gallery integration.
- **Infrastructure**: Improved CI/CD pipelines for macOS by automating the generation of ephemeral files before pod installation.
- **Code Quality**: Performed various refactors to improve maintainability, including removing unused Podfiles and cleaning up redundant imports.
- **Documentation**: Updated `AGENT.md` with specifications for global player design and navigation enhancements.

**Files changed (key items)**

- **Features**: `lib/features/studios/`, `lib/features/tags/` (Favorite functionality)
- **Media Handling**: `lib/features/images/`, `lib/features/scenes/` (Download and save-to-gallery implementation)
- **Core Optimization**: `lib/core/data/graphql/`, `lib/features/scenes/presentation/providers/video_player_provider.dart`
- **Localization**: `lib/l10n/` (Extensive updates and translations)
- **macOS Config**: `macos/Runner/Configs/AppInfo.xcconfig`, `macos/Podfile`
