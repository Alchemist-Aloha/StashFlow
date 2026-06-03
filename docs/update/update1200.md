# StashFlow v1.20.0

## ✨ New Features

*   **Saved Presets Integration**: A massive enhancement to content discovery! You can now load and apply your Stash server's Saved Filters (Presets) directly within the app. This feature is fully supported across all major tabs: Scenes, Galleries, Images, Performers, Studios, and Tags. 
*   **Dynamic UI Layouts**: Action buttons (Sort, Filter, and Saved Presets) have been modernized. For most layouts, they now reside in a sleek floating pill at the bottom of the screen that dynamically avoids the mini-player. For the TikTok-style feed view, they seamlessly relocate to the top app bar to maximize vertical space.

## 🎨 UI & UX Improvements

*   **Consistent Sort Panels**: Harmonized the vertical size of sort and filter panels across the entire app, ensuring a uniform and predictable user experience.
*   **Palette Interaction**: Improved text link accessibility and interaction feedback within the app's palette and thematic elements.
*   **Mini-Player Polish**: Fixed layout constraints to prevent the mini-player from overlapping list content and producing blank spaces when inactive.
*   **Smooth Scrolling**: Optimized rendering logic in grid and list views by hoisting lookup maps out of the `itemBuilder`, significantly reducing stuttering and GC pressure during fast scrolls.

## 🌍 Localization & Security

*   **Translated Security Settings**: The Security Settings page and App Lock Gate are now fully localized with multi-language support.

## 🛠 Under the Hood

*   **CI/CD Enhancements**: Introduced a new Release Candidate workflow and updated macOS build targets to `macos-26` for faster, more reliable Apple builds.
*   **Dependency Updates**: Upgraded Dart, Flutter SDK constraints, Gradle, and multiple backend dependencies to their latest stable versions for improved security and performance.
*   **Codebase Polish**: Cleaned up legacy null-checks by migrating to Dart 3 null-aware map elements (`?key: value`), removed deprecated Flutter list callbacks, and eliminated unused parameters across widgets.
