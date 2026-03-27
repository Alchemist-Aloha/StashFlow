# Docs Index

This folder contains agent-focused project documentation.

## Start Here

- [Developer Guide](./DEVELOPER_GUIDE.md) (Architecture, Commands, Setup, UI Guidelines)
- [Troubleshooting](./TROUBLESHOOTING.md) (Debugging Playbook, Known Issues)
- [Roadmap](./ROADMAP.md) (Current Tasks and Plans)

### Scene editor

The Scene Details editor (metadata scraping and manual edits) is documented in the Developer Guide under "Scene Details Editor — dev notes". See [docs/DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md) for testing guidance and provider notes.

## Quick Build & Run

Quick commands to get the project running locally:

For release builds use:

```bash
flutter build apk --split-per-abi
```

## Current Implementation Notes (2026-03-25)

- **Tablet Optimization:**
    - Implemented **Adaptive Navigation**: side-rail (`NavigationRail`) for screens >= 600px width, bottom-bar (`NavigationBar`) for smaller screens.
    - Updated `ShellPage` to handle responsive layout transitions while maintaining consistent routing.
- **Responsive Grid System:**
    - Enhanced `ListPageScaffold` to support `mobileCrossAxisCount` and `tabletCrossAxisCount` overrides.
    - Simplified grid delegate logic to use width-based breakpoint checks directly for more reliable layout switching.
    - **Performers List:** Optimized with 3 columns on mobile and 5 columns on tablet.
    - **Scene/Studio/Tag Grids:** Refined to 2 columns on mobile and 3 columns on tablet.
- **Performer UI Refinement:**
    - Switched to **circular thumbnails** for performers using `ClipOval`.
    - Integrated `LayoutBuilder` in `PerformerCard` to ensure perfectly square aspect ratios for circles, preventing vertical/horizontal stretching regardless of grid cell dimensions.
- **Robustness & Testing:**
    - Refactored `SettingsPage` layouts (Seek Interaction, Connection Status) to use `Wrap` and `Expanded` to prevent overflows on extremely narrow screens.
    - Updated integration tests to use `physicalSize` and re-pumping logic to accurately verify responsive behaviors.
- **Build Process:**
    - Verified and documented `flutter build apk --split-per-abi` for optimized deployment sizes.

## Current Implementation Notes (2026-03-24)

- Refined Scenes layout options: List, Grid, and TikTok (Infinite Scroll).
- Optimized List view with dynamic aspect ratios based on scene metadata to prevent image distortion.
- Improved Grid layout with increased vertical breathing room (`childAspectRatio: 1.15`) and row spacing (`mainAxisSpacing: 16dp`) for metadata.
- Ensured all scene thumbnails use `BoxFit.cover` with `double.infinity` dimensions to perfectly fill their containers.
- Simplified Scenes page UI by moving layout selection exclusively to the Settings page.
- Added detailed docstrings to `ScenesPage` and `SceneCard` documenting the layout and prefetch logic.

## Current Implementation Notes (2026-03-20)

- Dedicated full-screen navigation route (`/fullscreen/:id`) implemented for robust back-gesture and orientation management.
- Global setting added to toggle visibility of "Random" navigation/discovery buttons.
- Dynamic "Playlist" strategy implemented: "Play Next" now follows the current query sequence (sort/filter) if the manual queue is empty.
- Scene rating functionality (1-100 range) integrated into `SceneDetailsPage` with a 5-star UI.
- Expanded sorting options for Performers, Studios, and Tags (Rating, Date Created, Scene/Image/Gallery counts).
- Standard and TikTok views updated to use `context.push()` for entering full-screen mode.

## Current Implementation Notes (2026-03-19)

- Scenes/Performers/Studios/Tags use bottom-sheet sort and filter menus.
- Random discovery uses small floating action buttons on all four list pages.
- Scenes "Organized only" filter lives in the filter panel.
- Scenes grid/list layout is controlled from Settings (`scene_grid_layout`).
- Video seek interaction mode is configurable in Settings (`Drag` vs `Double-tap`) and works in inline and fullscreen player.
- Player controls now auto-hide while playing and reappear on interaction.
- Stream prewarm runs in the background and no longer blocks playback startup.
- Mini-player navigation back to scene details preserves current playback session (no intentional restart).
- Native PiP is enabled as an optional setting; PiP entry prefers fullscreen player context for video-only surface.
- Startup diagnostics include stream resolver and player startup logs; provider lifecycle race is still being monitored.
- Startup timing now includes resolver, probe, prewarm, initialize, Chewie build, and first-frame markers for phase-by-phase attribution.
- Latest measurements indicate first-play delay is dominated by native initialize/upstream path, not Chewie controller/UI loading.
- Resolver now tolerates cache re-read exceptions when stream data is present and continues with available stream candidates.
- Scene title fallback is hardened against malformed percent-encoded paths.
- GraphQL codegen maps to `graphql/combined_schema.graphql` and feature documents.

## Purpose

Use these docs to reduce exploration time, avoid repeated mistakes, and keep changes verifiable.

## Historical Design/Plan Docs

- `docs/superpowers/plans/*` and `docs/superpowers/specs/*` are historical planning artifacts.
- They are retained for context and may not exactly match current implementation.

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) for current UI standards.