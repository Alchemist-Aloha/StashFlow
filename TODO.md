# StashAppFlutter Functions + UI Improvement Plan (2026-03-19)

> For agent workers: execute in small vertical slices and verify each slice with `flutter analyze` + targeted tests.

## Current State Summary

### What is working

- Core feature coverage is broad (scenes, performers, studios, tags, galleries, groups).
- Runtime settings for server URL, API key, and stream strategy are in place.
- Stream diagnostics are available (mime/source/startup timing).
- Routing and details pages exist for major entities.

### Main gaps observed

- UI consistency is uneven across pages (spacing, density, typography, color usage).
- Error/empty/loading states are inconsistent and often low-context.
- Search/filter interactions vary by page and are not centrally reusable.
- Infinite-scroll pagination triggers are duplicated and likely to diverge.
- First-play startup latency still unresolved (known issue).

## Priority Goals

1. Improve reliability of list/details flows and playback startup behavior.
2. Standardize UX patterns across pages (app bars, states, cards, actions).
3. Reduce code duplication in pagination/search/state handling.
4. Increase test confidence around critical async flows.

---

## Phase 1: Functional Reliability Baseline

### Task 1.1: Pagination guardrails

- [x] Add a reusable pagination trigger utility/provider mixin for list pages.
- [x] Prevent duplicate `fetchNextPage()` calls when already loading.
- [x] Add page-end threshold constants in one place.

Candidate files:
- `lib/features/scenes/presentation/providers/scene_list_provider.dart`
- `lib/features/performers/presentation/providers/performer_list_provider.dart`
- `lib/features/studios/presentation/providers/studio_list_provider.dart`
- `lib/features/tags/presentation/providers/tag_list_provider.dart`

Validation:
- [ ] Scroll-to-end tests or provider-level tests verify no duplicate loads.

### Task 1.2: Stream startup instrumentation hardening

- [x] Record prewarm execution result and timing (success/failure, ms) in player debug state.
- [x] Add explicit marker when startup path was prewarmed.
- [x] Keep prewarm best-effort and non-fatal.

Candidate files:
- `lib/features/scenes/presentation/widgets/scene_video_player.dart`
- `lib/features/scenes/presentation/providers/video_player_provider.dart`

Validation:
- [ ] Manual run confirms debug info differentiates cold vs warmed attempt.

### Task 1.3: Unified retry/error messaging

- [x] Create shared error widget with retry callback and contextual message.
- [x] Replace ad-hoc `Text('Error: ...')` sections in major pages.

Candidate files:
- `lib/core/presentation/widgets/` (new shared widget)
- `lib/features/scenes/presentation/pages/scenes_page.dart`
- `lib/features/performers/presentation/pages/performers_page.dart`
- other list/details pages with inline error text

Validation:
- [ ] Widget tests for retry callback and message rendering.

---

## Phase 2: UI Cohesion and Navigation UX

### Task 2.1: Design tokens + app theme refinement

- [ ] Replace scattered hardcoded colors with a centralized theme extension.
- [ ] Define spacing scale, radius scale, and semantic text styles.
- [ ] Keep dark mode but remove random one-off color choices.

Candidate files:
- `lib/main.dart`
- `lib/core/presentation/theme/` (new)

Validation:
- [ ] Major pages compile and visually align without per-page overrides.

### Task 2.2: Standardize list page shell

- [ ] Build reusable list-page scaffold supporting:
	- title + search affordance
	- grid/list toggle (optional)
	- refresh
	- empty/loading/error slots
- [ ] Migrate Scenes/Performers first, then Studios/Tags.

Candidate files:
- `lib/core/presentation/widgets/` (new scaffold)
- `lib/features/scenes/presentation/pages/scenes_page.dart`
- `lib/features/performers/presentation/pages/performers_page.dart`

Validation:
- [ ] Consistent top spacing/action layout across migrated pages.

### Task 2.3: Details page information hierarchy

- [ ] Improve scene details readability: metadata chips, section headers, performer actions.
- [ ] Align performer/studio/tag detail sections to same visual hierarchy.
- [ ] Ensure touch targets are comfortable on mobile.

Candidate files:
- `lib/features/scenes/presentation/pages/scene_details_page.dart`
- corresponding details pages in performers/studios/tags

Validation:
- [ ] Golden tests for at least one details page state.

---

## Phase 3: Maintainability and Reuse

### Task 3.1: Shared search query pattern

- [ ] Extract common search state/behavior for list pages.
- [ ] Normalize debounce behavior and clear semantics.

Candidate files:
- list page widgets + query providers

Validation:
- [ ] Tests for search update + clear behavior.

### Task 3.2: Shared media strip + “View all” contracts

- [ ] Unify horizontal media strip UI and pagination contracts used by performer/studio/tag details.
- [ ] Standardize route naming and argument passing for media grids.

Candidate files:
- media strip widgets/providers in performers/studios/tags
- `lib/features/navigation/presentation/router.dart`

Validation:
- [ ] Route tests for all `/:id/media` paths.

### Task 3.3: Documentation and runbook updates

- [ ] Keep known issue notes current as latency findings evolve.
- [ ] Update debug playbook with new telemetry keys.
- [ ] Add troubleshooting matrix by symptom.

Candidate files:
- `docs/superpowers/KNOWNISSUES.md`
- `docs/DEBUGGING_PLAYBOOK.md`

---

## Verification Checklist Per Phase

- [ ] `flutter analyze`
- [ ] `flutter test` (or targeted tests for changed modules)
- [ ] `flutter build apk` for release-impacting changes
- [ ] Manual smoke test: settings save, list browse, detail open, first playback

## Suggested Execution Order

1. Phase 1 (stability and diagnostics)
2. Phase 2 (UI standardization)
3. Phase 3 (reuse and long-term maintainability)

---

## High-Impact Feature Backlog (Added 2026-03-19)

### 1) Smart sorting everywhere

- [ ] Add sort chips on Scenes, Performers, Studios, Tags.
- [ ] Scene sort options: Date newest, Date oldest, Rating, Play count, Random.
- [ ] Performer sort options: Name, Scene count, Last updated.

Value:
- Immediate usability boost for large libraries.

Effort:
- Medium.

Best starting points:
- `lib/features/scenes/presentation/pages/scenes_page.dart`
- `lib/features/performers/presentation/pages/performers_page.dart`

### 2) Random navigation and discovery mode

- [ ] Add a Random button in app bar and details pages.
- [ ] Add global random scene mode.
- [ ] Add contextual random scene mode within performer/studio/tag scope.
- [ ] Add a `Surprise Me` entry in bottom-nav shell overflow.

Value:
- Strong engagement feature, low cognitive load.

Effort:
- Low to medium.

Best starting points:
- `lib/features/navigation/presentation/shell_page.dart`
- `lib/features/scenes/presentation/pages/scene_details_page.dart`

### 3) Rich details blocks

- [ ] Scene details: duration, file size, resolution, fps, codec, bitrate.
- [ ] Scene details: tappable tags that navigate to tag details.
- [ ] Performer details: age calculation, aliases, social links, top tags, frequent co-stars.
- [ ] Studio/tag details: top performers, top scenes, trend summaries.

Value:
- Makes details pages feel premium and informative.

Effort:
- Medium to high (depends on GraphQL field availability).

Best starting points:
- `lib/features/scenes/presentation/pages/scene_details_page.dart`
- `lib/features/performers/presentation/pages/performer_details_page.dart`

### 4) Multi-filter panel

- [ ] Add scenes bottom-sheet filter panel.
- [ ] Filters: date range, rating min, studio, performer.
- [ ] Filters: tags include/exclude, watched/unwatched.
- [ ] Save and restore last-used filter preset.

Value:
- Major power-user feature.

Effort:
- Medium.

Best starting point:
- `lib/features/scenes/presentation/pages/scenes_page.dart`

### 5) Playback queue and next-up

- [ ] Add `Add to queue` from list/detail entry points.
- [ ] Show `Up Next` suggestions on scene details (same performer/studio/tag).
- [ ] Add autoplay-next toggle.

Value:
- Improves session depth and continuous playback.

Effort:
- Medium.

Best starting points:
- `lib/features/scenes/presentation/widgets/scene_video_player.dart`
- `lib/features/scenes/presentation/providers/video_player_provider.dart`

### 6) Make Galleries and Groups first-class

- [ ] Add search and sorting for galleries/groups.
- [ ] Add details pages for galleries/groups.
- [ ] Add media-strip consistency with other detail pages.

Value:
- Closes obvious product gap in currently thin pages.

Effort:
- Medium.

Best starting points:
- `lib/features/galleries/presentation/pages/galleries_page.dart`
- `lib/features/groups/presentation/pages/groups_page.dart`

## Fastest Visible-Wins Roadmap

1. [ ] Sorting plus random navigation.
2. [ ] Scene detail enrichment plus filter panel.
3. [ ] Queue and next-up autoplay.
4. [ ] Galleries and groups full UX pass.
