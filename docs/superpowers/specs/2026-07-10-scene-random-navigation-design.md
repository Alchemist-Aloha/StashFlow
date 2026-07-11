# Scene random navigation design

## Goal

Make all scene-random actions use one shared policy and one backend-random
resolution path.

The affected entry points are:

- `ScenesPage` random FAB
- `SceneDetailsPage` random FAB
- fullscreen scene player random button

## Required behavior

- Add a persisted setting that controls whether scene-random navigation
  respects the active scene filters.
- When the setting is `true`, random scene resolution must use the active
  scene search query, scene filter state, and organized filter state.
- When the setting is `false`, random scene resolution must ignore those
  active scene filters and resolve from the full scene set.
- Every scene-random action must resolve a true random scene from the backend.
  None of them may sample from the currently loaded client list.
- Random navigation must not rewrite or replace the current playback queue.
  The main queue should continue to represent the main scene list page state.
- Random navigation should avoid returning the currently open scene when an
  exclusion id is available.
- Existing empty-state behavior should stay consistent: if no random scene is
  available, show the existing no-random snackbar/message.

## Architecture

Reuse the existing `SceneList.getRandomScene(...)` backend-random path and put
one thin scene-specific Riverpod controller in front of it.

Responsibilities:

- read the persisted `respect active filter` setting
- call `SceneList.getRandomScene(...)` with the correct filter mode
- optionally exclude the current scene id
- return the resolved scene without mutating the playback queue

This controller is the only shared abstraction for scene-random UI. Do not add
a separate store, repository, service, or queue layer for this feature.

## Settings

Put the new toggle in `InterfaceSettingsPage`, adjacent to the existing random
navigation visibility setting because this is global navigation behavior, not
player-only behavior.

Persist it with the same shared-preferences provider pattern already used by
other interface settings so scene pages and player controls watch one source of
truth. Do not add a separate settings store just for this bool.

## UI changes

### Scene list page

Replace the current loaded-list sampling logic with the shared random
controller. The button should navigate to the resolved random scene and leave
the main playback queue untouched.

### Scene details page

Replace the current hardcoded `useCurrentFilter: true` behavior with the shared
controller so it honors the same toggle as the list page.

### Fullscreen player

Add a fullscreen-only random button to the scene player controls and wire it to
the shared random controller.

The button should:

- only appear for scene playback surfaces
- respect the global random-navigation visibility setting
- resolve the next scene through the shared controller
- navigate to the resolved scene without rewriting the main queue

## Data flow

1. User taps a scene-random button.
2. UI calls the shared scene-random controller.
3. Controller reads the persisted filter-respect setting.
4. Controller calls `SceneList.getRandomScene(...)` using either active scene
   filter state or an empty filter scope.
5. UI navigates to the resolved scene details route or fullscreen scene route
   as appropriate.
6. Playback queue state remains unchanged.

## Testing

- provider/store tests for the new setting default and persistence
- settings page test for the new toggle
- scene random-controller tests for filter-aware vs unfiltered resolution
- `ScenesPage` test that random navigation no longer samples the loaded list
- `SceneDetailsPage` test that random navigation follows the shared setting
- fullscreen controls test that the random button appears in fullscreen and
  triggers the provided callback
- regression coverage that random navigation does not modify the main playback
  queue

## Risks and constraints

- `SceneList.getRandomScene(...)` currently has a loaded-list fallback. Keep it
  only as an internal last-resort safeguard if the backend-random call fails;
  the intended UI path must remain backend-random.
- Fullscreen navigation must preserve the current playback ownership rules and
  must not introduce a second, player-owned queue concept.
- The feature should land as a small diff over existing scene navigation and
  preference patterns, not as a new generic navigation framework.
