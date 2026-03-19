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

- [x] Replace scattered hardcoded colors with a centralized theme extension.
- [x] Define spacing scale, radius scale, and semantic text styles.
- [x] Keep dark mode but remove random one-off color choices.

### Task 2.2: Standardize list page shell

- [x] Build reusable list-page scaffold supporting:
	- title + search affordance
	- grid/list toggle (optional)
	- refresh
	- empty/loading/error slots
- [x] Migrate Scenes/Performers first, then Studios/Tags.

### Task 2.3: Details page information hierarchy

- [x] Improve scene details readability: metadata chips, section headers, performer actions.
- [x] Align performer/studio/tag detail sections to same visual hierarchy.
- [x] Ensure touch targets are comfortable on mobile.

---

## Phase 3: Maintainability and Reuse

### Task 3.1: Shared search query pattern

- [x] Extract common search state/behavior for list pages.
- [x] Normalize debounce behavior and clear semantics.

### Task 3.2: Shared media strip + “View all” contracts

- [x] Unify horizontal media strip UI and pagination contracts used by performer/studio/tag details.
- [x] Standardize route naming and argument passing for media grids.

### Task 3.3: Documentation and runbook updates

- [x] Keep known issue notes current as latency findings evolve.
- [x] Update debug playbook with new telemetry keys.
- [x] Add troubleshooting matrix by symptom.

---

## Verification Checklist Per Phase

- [x] `flutter analyze`
- [x] `flutter test` (or targeted tests for changed modules)
- [x] `flutter build apk` for release-impacting changes
- [x] Manual smoke test: settings save, list browse, detail open, first playback

## Suggested Execution Order

1. Phase 1 (stability and diagnostics)
2. Phase 2 (UI standardization)
3. Phase 3 (reuse and long-term maintainability)

---

## High-Impact Feature Backlog (Added 2026-03-19)

### 1) Smart sorting everywhere

- [x] Add sort chips on Scenes, Performers, Studios, Tags.
- [x] Scene sort options: Date newest, Date oldest, Rating, Play count, Random.
- [x] Scene deterministic sorts (Newest, Oldest, Rating, Play Count) now use server-side query sorting.
- [x] Performer sort chips implemented (Name, Scene Count, Last Updated, Random).
- [x] Performer deterministic sorts (Name, Scene Count, Last Updated) now use server-side query sorting.
- [x] Add sort chips for Studios and Tags.
- [ ] Add true `Last updated` sorting for performers when backend field is available.

### 2) Random navigation and discovery mode

- [x] Add a Random button in app bar and details pages.
- [x] Add global random scene mode.
- [x] Add contextual random scene mode within performer/studio/tag scope.
- [x] Add a `Surprise Me` entry in bottom-nav shell overflow.

### 3) Rich details blocks

- [x] Scene details: duration, file size, resolution, fps, codec, bitrate.
- [x] Scene details: tappable tags that navigate to tag details.
- [x] Performer details: age calculation, aliases, social links, top tags, frequent co-stars.
- [x] Studio/tag details: top performers, top scenes, trend summaries.

### 4) Multi-filter panel

- [x] Add scenes bottom-sheet filter panel.
- [x] Filters: date range, rating min, studio, performer.
- [x] Filters: tags include/exclude, watched/unwatched.
- [x] Save and restore last-used filter preset.

### 5) Playback queue and next-up

- [x] Add `Add to queue` from list/detail entry points.
- [x] Show `Up Next` suggestions on scene details (same performer/studio/tag).
- [x] Add autoplay-next toggle.

### 6) Make Galleries and Groups first-class

- [x] Add search and sorting for galleries/groups.
- [x] Add details pages for galleries/groups.
- [x] Add media-strip consistency with other detail pages.

## Fastest Visible-Wins Roadmap

1. [x] Sorting plus random navigation.
2. [x] Scene detail enrichment plus filter panel.
3. [x] Queue and next-up autoplay.
4. [x] Galleries and groups full UX pass.
