# Agent Start Guide

## 1) Understand the current baseline

1. Read known issues first: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md).
2. Scan architecture map: [#architecture-map](#architecture-map).
3. Check project health quickly:
   - `flutter analyze`
   - `flutter test`

## 2) Configuration expectations

- Runtime server settings are stored in SharedPreferences:
  - `server_base_url`
  - `server_api_key`
  - `prefer_scene_streams`
  - `scene_grid_layout`
- URL normalization is required when user inputs host/path without scheme.
- Media requests may require `ApiKey` header even if GraphQL works.

## 3) Safe change flow

1. Reproduce problem.
2. Identify owner layer (UI, provider, repository, GraphQL, platform).
3. Make minimal code edits.
4. Verify with analyze/tests and, if relevant, `flutter build apk`.
5. Update docs if behavior or debugging guidance changed.

## 4) Common high-value checks

- Android networking in release depends on INTERNET permission in main manifest.
- Stream startup issue may be server warm-up related, not MIME mismatch.
- Relative media paths should be resolved against GraphQL endpoint.

## 5) Definition of done for bugfixes

- Repro case before and after is documented.
- No analyzer errors.
- No test regressions in touched area.
- Any new toggle/setting is persisted and visible in settings UI.

## 6) Current UI conventions

- List pages use `ListPageScaffold` where possible.
- Sort/filter controls should use app bar actions + bottom sheets.
- Random discovery actions should use floating action buttons on list pages.

## Scene Details Editor — dev notes

- Location: `SceneDetailsPage` opens the editor dialog implemented in `lib/features/scenes/presentation/widgets/scene_edit_dialog.dart`.
- Feature toggle: The editor/scrape UI is controlled by `scrapeEnabledProvider` (backed by the `show_scrape_button` SharedPreferences key). Toggle in Settings to enable scraping/editing in the running app.
- Behavior summary: The editor can run configured scrapers, merge or replace metadata, preview scraped images (supports `data:` URIs), and save changes via `sceneScrapeProvider.saveScraped(...)`. On success the dialog invalidates `sceneDetailsProvider(id)` and `sceneListProvider` to refresh UI state.
- Testing guidance:
  - Wrap widgets in `ProviderScope` and override `sceneScrapeProvider` with a test double that implements `scrapeScene(...)` and `saveScraped(...)` to avoid network or repository side effects.
  - If the app uses synchronous provider consumers at startup, initialize required singletons (for example `SharedPreferences`) in `main()` or override the provider in tests to avoid flaky initialization.
  - After changing providers or generated files, run `dart run build_runner build --delete-conflicting-outputs`.

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [#ui-guideline](#ui-guideline) for current UI standards.

# Architecture Map

## App Stack

- Flutter app
- State management: Riverpod + generated providers
- Navigation: GoRouter
- Data: GraphQL (`graphql_flutter` + generated models)
- Persistence: SharedPreferences
- Video: `video_player` + `chewie`

## Key Folders

- `lib/core`
  - Shared infrastructure (GraphQL client, prefs provider, URL/header helpers)
- `lib/features`
  - Domain modules: scenes, performers, studios, tags, galleries, groups, setup, navigation
- `lib/features/setup`
  - Runtime server settings UI
- `lib/features/scenes`
  - Scene list/details, stream resolution, player startup diagnostics
- `graphql`
  - Schemas and source operation files
- `test` and `integration_test`
  - Unit/widget/integration coverage

## Stream Playback Path (high level)

1. Scene details opens player widget.
2. Settings decide source strategy:
   - prefer scene streams, or
   - direct `paths.stream`.
3. URL is resolved; headers are attached.
4. Optional one-time prewarm request runs.
5. Video controller initializes and starts playback.
6. Debug label shows MIME, source, and startup timing.

## Runtime settings that affect behavior

- `server_base_url`
- `server_api_key`
- `prefer_scene_streams`
- `scene_grid_layout` (Controls the Grid vs List view)
- `scene_tiktok_layout` (Enables the infinite scroll vertical video feed)

## List UX Pattern (current)

- Shared shell: `ListPageScaffold`
- Search in app bar
- Sort and filter via modal bottom sheets
- Active sort/filter indicators in app bar actions
- Random discovery via `FloatingActionButton.small`
- **Responsive Grids**: Automatically scales column counts based on device width (Mobile < 600px, Tablet >= 600px). Supports `mobileCrossAxisCount` and `tabletCrossAxisCount` overrides.
- **Performers Specific**: Uses circular thumbnails with 3 columns on mobile and 5 on tablet.
- **Scenes Specific**: Supports three layout modes (List, Grid, TikTok) configured via Settings. List view uses dynamic aspect ratios to match media content. Grid view uses an optimized 1.15 aspect ratio for metadata breathing room.

## GraphQL Source of Truth

- Schema used for generation: `graphql/combined_schema.graphql`
- Feature operation documents: `lib/features/**/*.graphql`
- Generated types: `lib/core/data/graphql/schema.graphql.dart` and feature `*.graphql.dart`

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [#ui-guideline](#ui-guideline) for current UI standards.

# Commands

## Daily development

```bash
flutter pub get
flutter analyze
flutter test
```

## Build APK

```bash
# Universal APK
flutter build apk

# Split by ABI (recommended for deployment)
flutter build apk --split-per-abi
```

## Fast smoke flow after UI/data changes

```bash
flutter analyze
flutter test
flutter build apk
```

## Regenerate code (when GraphQL/provider/model sources change)

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Helpful focused checks

```bash
flutter test test/scenes_page_mock_repo_test.dart
flutter test integration_test/core_flow_test.dart
```

## Optional cleanup and refresh

```bash
flutter clean
flutter pub get
```

## Suggested verification order for risky fixes

1. `flutter analyze`
2. Targeted tests if available
3. Full `flutter test`
4. `flutter build apk` for release-path validation

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [#ui-guideline](#ui-guideline) for current UI standards.

# Change Checklist

Use this before closing a task.

## Code changes

- [ ] Minimal scope; no unrelated refactors.
- [ ] New behavior is behind existing patterns or settings when appropriate.
- [ ] SharedPreferences keys are stable and documented if added.
- [ ] List-page random actions use floating buttons (not app bar icons).
- [ ] Sort/filter changes follow bottom-sheet control pattern.

## Validation

- [ ] `flutter analyze` passes.
- [ ] Relevant tests pass.
- [ ] `flutter build apk` run for release-impacting changes.

## Documentation

- [ ] Known issues updated if problem remains unresolved.
- [ ] New runtime toggles are reflected in docs.
- [ ] Debugging notes updated for newly learned failure modes.
- [ ] `README.md` and `docs/README.md` updated when UX/flow changes are user-visible.

## Handoff quality

- [ ] Root cause or best-known hypothesis stated.
- [ ] Trade-offs and limits are explicit.
- [ ] Next action is clear and testable.

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [#ui-guideline](#ui-guideline) for current UI standards.

# UI Guideline

## Purpose
This document defines practical UI standards for the StashFlow project.
Use these rules for new UI work and when refactoring existing screens.

## Core Principles
- Keep interactions fast, predictable, and touch friendly.
- Prefer clarity over visual density.
- Use Material 3 components and tokens by default.
- Keep behavior consistent across scenes, performers, studios, tags, and settings.

## Theming
- Respect app theme mode: `system`, `light`, and `dark`.
- Never hardcode light-only or dark-only text colors for primary content.
- Prefer theme tokens from `ThemeData` and `AppColors` extensions.
- Ensure contrast is readable in both light and dark themes.

## Layout
- Use consistent spacing from `AppTheme` constants.
- **Adaptive UI**: Use `NavigationRail` for tablets (>= 600px) and `NavigationBar` for phones.
- **Responsive Grids**: Use `ListPageScaffold` with width-aware column counts to optimize screen usage.
- Avoid fixed-width assumptions unless required by a specific component.
- For media surfaces, prefer dynamic aspect ratio from metadata/controller values.

## Typography
- Use `context.textTheme` styles as the base.
- Reserve bold weights for headings and key values.
- Limit long text with sensible truncation and fallback states.
- Provide title fallback for scene-derived content when upstream titles are missing.

## Components
- Prefer Material 3 widgets when available.
- Use cards, chips, list tiles, segmented controls, and FAB patterns consistently.
- Keep reusable UI in widgets/providers instead of duplicating logic.
- Avoid custom controls unless default controls cannot meet UX requirements.

## Motion and Gestures
- Support intuitive gestures where they add value.
- Keep gesture behavior explicit to avoid accidental actions.
- For video controls:
  - keep drag-to-seek enabled,
  - support double-tap seek where appropriate,
  - avoid accidental resume/play from generic tap areas.

## Media and Playback UX
- Ensure portrait media is not forced into landscape framing.
- Keep mini player state, detail player state, and queue behavior in sync.
- Keep screen awake while video is actively playing.
- Expose debugging overlays only behind explicit settings toggles.

## Accessibility
- Maintain readable text size and color contrast.
- Ensure touch targets are large enough for mobile use.
- Avoid icon-only actions without a tooltip/semantic meaning.
- Keep navigation and section structure clear and screen-reader friendly.

## Empty, Loading, and Error States
- Always provide explicit loading and empty states.
- Show actionable error messages and recovery options when possible.
- Never leave major content regions blank without context.

## Documentation Rule
When adding or changing UI behavior:
- update the relevant docs in `docs/`,
- note theme and accessibility implications,
- include any new interaction patterns.
- include detailed docstrings in the code. 