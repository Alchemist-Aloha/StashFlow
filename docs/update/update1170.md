# Update 1.17.0

## Scene Details Sheet

- Fixed sheet layering so it always appears above mini player overlays.
- Added a Scene Details page app-bar button to open the same sheet used by long-press on scene cards.
- Expanded sheet content and organization:
  - Core metadata and technical fields
  - Original file path
  - URLs
  - Clickable studio / performers / tags
  - Expandable tags (`show more` / `show less`)
- Unified behavior across entry points by hydrating from `sceneDetailsProvider(scene.id)` when needed.
- Tapping studio/performer/tag now closes the sheet before navigation.
- Capped sheet height to keep top spacing and avoid full-height visual crowding.

## Scene Details Sheet Performance

- Refactored sheet rendering for lower rebuild/repaint cost:
  - Switched container layout to `ListView`
  - Localized tag expansion state with `ValueNotifier` + `ValueListenableBuilder`
  - Added `RepaintBoundary` around heavier sections
  - Reduced `SelectableText` usage to only heavy fields (path/URLs/details)

## Library Stats Loading UX

- Replaced spinner-only loading in Library Stats panel with skeletonized stat item placeholders for a more stable, polished loading state.

## Playback & Feed Behavior

- Added a settings option to start feed playback from a random position.
- Updated playback settings tests to cover the new behavior and persistence.

## Scene Feed / Navigation Performance

- Hoisted expensive `GoRouter` lookups out of list/grid item builders (including TikTok scenes flow) to reduce per-item rebuild overhead.
- Applied minor UI-path cleanups in scene/studio/performer/tag media pages to reduce repeated work in hot scrolling paths.

## Cache Management Improvements

- Hardened cache cleaning implementation:
  - Standardized cache roots
  - Reduced risky broad-directory cleanup
  - Surfaced partial failures instead of silently swallowing errors
- Implemented cache-limit enforcement (not just manual clear):
  - Added image/video cache size limit enforcement with oldest-first pruning
  - Wired settings changes to trigger immediate enforcement and refresh displayed sizes
- Added unit tests for cache-limit enforcement behavior.

## Desktop Runtime UX

- Added `screen_retriever` and improved desktop window initialization:
  - Better initial size/position handling on desktop startup.

## Android Performance / Release Build

- Enabled release shrinking/optimization:
  - `isMinifyEnabled = true`
  - `isShrinkResources = true`
  - Added `proguard-rules.pro`
- Tuned Android in-memory image cache defaults to reduce GC pressure:
  - Lowered max cache entries and bytes for Android runtime.
- Fixed release build failure from plugin registrant mismatch by pinning:
  - `screen_brightness_android: 2.1.3` via `dependency_overrides`
- Verified split-per-ABI release build succeeds.

## Build/CI Compatibility

- Addressed macOS CI build instability related to `connectivity_plus` API/toolchain compatibility.
- Removed `connectivity_plus` as a direct dependency (it remains transitive via `graphql_flutter`).
- Pinned transitive `connectivity_plus` to `7.0.0` via `dependency_overrides` for stable macOS builds.

## Localization & Form UX

- Replaced remaining hardcoded strings with l10n keys in affected UI paths.
- Improved text-field keyboard navigation and form submission flow.
- Added input-action and semantic-label improvements for better accessibility/UX.
- Cleaned up localization formatting (including Chinese locale whitespace fixes).

## Stability & Maintenance

- Fixed conditional-brace issues in performer edit flow.
- Updated dependency lockfile and bumped project version metadata to `1.17.0`.

## Test Coverage Expansion

- Added significant edge-case tests across:
  - Scene title derivation / filestem fallback logic
  - Scrape normalization and validation logic
  - Stats result parsing defaults/coercions
  - Playback queue boundary/index behavior
  - URL/auth fallback behavior
- Added cache enforcement tests with deterministic temp-directory fixtures.
