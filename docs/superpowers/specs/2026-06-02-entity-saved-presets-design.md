# Entity Saved Presets Design

## Goal

Extend the scene-style named saved preset workflow to performers, studios, tags, images, and galleries so each page can save and load server-backed presets containing the current search query, sort field, sort direction, and effective filter state.

## Current Problems

- `ScenesPage` is the only list page with a named preset workflow exposed from the app bar.
- The other list pages only persist a single local default via `SharedPreferences`.
- The current scene implementation is feature-specific, so copying it directly would create six divergent preset flows.
- Several entity pages have effective filter state that spans more than one provider, so a naive reuse of the scene code would miss part of what the user sees on screen.

## Non-Goals

- No change to the existing "save as default" buttons or `SharedPreferences` behavior.
- No new preset delete, rename, or reorder UI.
- No change to server-side saved filter semantics.
- No unrelated refactor of list pages beyond what is needed to support presets cleanly.

## Reference Pattern

`ScenesPage` is the behavioral source of truth:

- bookmark action in the app bar opens a saved presets bottom sheet
- save flow prompts for a preset name and stores the current page state on the server
- load flow restores search query, sort, direction, and filter state, then refreshes the list
- the bottom sheet uses the compact Material 3 layout already implemented for scenes

The new pages should match that behavior exactly.

## Proposed Architecture

Introduce a small shared saved-preset layer under `core` that separates:

1. shared preset UI
2. shared server repository mechanics
3. mode-specific config serialization and page integration

### Shared Preset UI

Create a generic dialog widget that mirrors `SceneSavedFilterDialog` structurally but is parameterized by:

- sheet title
- current config summary data
- async loader for saved presets
- async saver for saved presets
- load callback

This keeps the Material 3 sheet layout in one place and avoids cloning the same widget five more times.

### Shared Saved Config Contract

Define a generic saved preset model that stores:

- optional saved filter id
- preset name
- filter mode
- search query
- sort key
- descending flag
- optional per-page page size
- serialized object filter payload

Mode-specific adapters will handle translation between server payloads and local filter entities.

### Shared Server Repository

Replace the scene-only repository shape with a reusable saved filter repository that can:

- load presets by `FilterMode`
- save a preset for a given `FilterMode`

The repository should stay thin: GraphQL query/mutation plus conversion hooks. Mode-specific logic should remain outside it.

### Mode-Specific Adapters

Each target feature will provide a small adapter/config type that knows how to:

- build a save payload for its filter mode
- parse a saved server payload back into local state
- report the effective filter count for summary display

This keeps page-specific mapping explicit instead of hiding conditional logic inside one large generic serializer.

## Filter Mode Coverage

Add preset support for:

- performers
- studios
- tags
- images
- galleries

Each one should use the server `FilterMode` that matches the page.

## Effective State Rules

Each preset must restore exactly what the user sees as active state on that page.

### Performers

- search query from `performerSearchQueryProvider`
- sort from `performerSortProvider`
- filter from `performerFilterStateProvider`

### Studios

- search query from `studioSearchQueryProvider`
- sort from `studioSortProvider`
- filter from `studioFilterStateProvider`

### Tags

- search query from `tagSearchQueryProvider`
- sort from `tagSortProvider`
- favorites-only filter from `tagFavoritesOnlyProvider`

### Images

- search query from `imageSearchQueryProvider`
- sort from `imageSortProvider`
- filter from `imageFilterStateProvider.filter`
- organized toggle from `imageOrganizedOnlyProvider`

`galleryId` should not be part of named presets because it represents page navigation context, not a reusable list filter. Loading a preset should preserve the current gallery context if the page is already scoped to one.

### Galleries

- search query from `gallerySearchQueryProvider`
- sort from `gallerySortProvider`
- filter from `galleryFilterStateProvider`
- organized toggle from `galleryOrganizedOnlyProvider`

## Page Integration

Each target page should gain:

- a bookmark `IconButton` beside sort/filter actions
- a `_showSavedFilterDialog()` method
- an `_applySavedFilterConfig(...)` method that mirrors scenes

Load behavior must:

- update local sort UI state used by the bottom sheet
- push restored search/filter/sort values into providers
- invalidate the list provider so data refreshes immediately

## UI Behavior

The saved presets sheet should be visually consistent across all six pages:

- same compact bottom-sheet shell as scenes
- same save icon/header action pattern
- same current settings summary
- same bounded presets list
- same name prompt dialog

Only the localized title/summary labels should differ by feature where needed.

## Testing Strategy

Use test-first coverage in three layers:

1. config parsing/serialization unit tests
2. repository tests for mode-aware saved filter loading and saving
3. widget tests for the reusable preset dialog and at least one non-scene page integration path

The tests should prove:

- the right `FilterMode` is queried and saved
- saved payloads round-trip into the correct local filter state
- the dialog still opens the naming prompt before saving
- loading a preset updates providers and refreshes the page state

## Risks

- Object filter key mapping differs by entity, so a shared serializer could silently produce invalid payloads.
- Tags use `favoritesOnly` instead of a full filter object, which is easy to omit during reuse.
- Images and galleries combine normal filter state with organized-only state, and losing either would make loaded presets incomplete.

## Mitigations

- Keep per-entity payload mapping in small dedicated adapters.
- Add explicit round-trip tests for tags, images, and galleries.
- Reuse the existing scene dialog layout rather than rewriting it independently per feature.

## Acceptance Criteria

- Performers, studios, tags, images, and galleries each expose a bookmark action that opens a saved presets sheet.
- Saving a preset stores the current search query, sort, direction, and effective filter state for that page on the server.
- Loading a preset restores those values into local providers and refreshes the corresponding list.
- The preset sheet behavior and layout match `ScenesPage`.
- Existing scene saved preset behavior remains intact.
- New and updated targeted tests pass.
