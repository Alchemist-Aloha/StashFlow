## Stage
- team-exec

## Goal / Non-goals
### Goals
- Move the "edit button" in the `SceneDetailsPage` from the actions row below the technical metadata to the top `AppBar`, matching the layout of `PerformerDetailsPage`. [DONE]
- Add a new nested `edit` route (`/scenes/scene/:id/edit`) to `router.dart` for handling scene editing via `context.push`. [DONE]
- Update `SceneDetailsPage` to use `context.push` for navigation to the edit page, passing the `Scene` object as `extra`. [DONE]

### Non-goals
- Changing the functionality of the `SceneEditPage`.
- Modifying other action buttons in the `SceneDetailsPage`.

## Task Graph
| Task ID | Priority | Task | Owner | Dependency | Path Type | Worktree | Baseline | Lane Notes | Validation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| M1 | p1 | Add `edit` route to `router.dart` under `/scenes/scene/:id` | omg-executor | - | critical | - | 823cdf4 | - | VERIFIED |
| M2 | p1 | Move edit `IconButton` to `AppBar` in `SceneDetailsPage` | omg-executor | M1 | sequential | - | 823cdf4 | - | VERIFIED |
| M3 | p1 | Remove old `FilledButton.tonalIcon` from `_buildActions` | omg-executor | M2 | sequential | - | 823cdf4 | - | VERIFIED |

## Critical Files
- `lib/features/scenes/presentation/pages/scene_details_page.dart`
- `lib/features/navigation/presentation/router.dart`

## Ready For team-prd
- Yes.
