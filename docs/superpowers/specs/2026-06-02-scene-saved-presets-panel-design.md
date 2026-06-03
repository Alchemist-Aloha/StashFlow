# Scene Saved Presets Panel Design

## Goal

Update the scenes saved presets panel so it feels consistent with the existing Material 3 sort panel: compact, structured, and action-oriented, while preserving the current save and load behavior.

## Current Problems

- The saved presets panel uses a near-fullscreen custom sheet, which feels heavier than the sort panel.
- The visual hierarchy is weaker than the sort panel: the current settings summary, saved presets list, and actions do not read as clearly separated sections.
- The presets list rows are functional but visually plain relative to the rest of the app's Material 3 surfaces.
- The panel styling is not obviously aligned with the sort panel's spacing, section labels, and action layout.

## Non-Goals

- No change to saved filter server behavior.
- No change to the save naming dialog workflow.
- No new preset editing, deleting, or reordering features.
- No cross-feature refactor of the sort panel.

## Reference Pattern

The sort panel in `ScenesPage` is the design reference:

- Content-driven bottom sheet height rather than a tall full-height panel.
- Clear header with title and lightweight action.
- Section labels using existing typography.
- Constrained scroll region for long content.
- Full-width primary action treatment where appropriate.
- Standard Material 3 controls and surfaces instead of custom framing.

## Proposed Layout

The saved presets panel should become a compact bottom sheet with bounded height and four vertical regions:

1. Header
   Title on the left, dismiss control on the right, and a save action that remains easy to find without dominating the sheet.

2. Current settings summary
   A compact tonal surface that summarizes what will be saved:
   - sort and direction
   - active filter count
   - search query when present

3. Saved presets section
   A labeled section containing a constrained scrollable list of presets.

4. Bottom spacing
   Standard bottom padding that respects the keyboard inset and safe area without turning the whole sheet into a full-screen surface.

## Component Behavior

### Header

- Use the same general structure as the sort panel: title-first, compact actions.
- Keep the save trigger in the header.
- Prefer a Material action presentation that feels native to the app rather than a custom toolbar treatment.
- Keep close behavior unchanged.

### Current Settings Summary

- Use a tonal Material surface (`surfaceVariant` or equivalent app token).
- Keep the copy short and functional.
- Use tighter chips than the current version so the summary reads as supporting context, not as the main feature.
- Omit the search chip when there is no query.

### Saved Presets List

- Use a section title and a constrained scrollable list similar in spirit to the sort chip region.
- Keep rows as standard Material list items with:
  - preset name as the title
  - condensed metadata as the subtitle
  - trailing load icon
- Sort order remains alphabetical by name.

### Empty State

- Keep the empty state inside the list region.
- Use compact spacing and neutral copy.
- Do not expand the sheet just to emphasize the empty state.

### Error State

- Keep the error state inside the list region.
- Preserve retry behavior.
- Use standard Material spacing and button styling.

### Save Dialog

- Preserve the current save dialog flow:
  - tap save action
  - prompt for preset name
  - save current settings to server
- No behavior changes beyond visual consistency if any dialog spacing tweaks are needed.

## Sizing

- Replace the current 90% height treatment with a content-driven sheet.
- Cap the presets list height so long preset collections scroll internally.
- Preserve keyboard-safe bottom padding for the naming dialog and any text input interaction.

## Styling

- Reuse existing typography from the scenes sort panel where possible:
  - larger title for the sheet heading
  - label-style section headers
  - standard body text for metadata
- Reuse the app's existing spacing tokens from `context.dimensions`.
- Keep corners and surfaces aligned with the app theme and Material 3 expectations.
- Avoid additional decorative containers or nested card-like framing.

## Implementation Scope

- Update `SceneSavedFilterDialog` layout and styling.
- Keep `SceneSavedFilterConfig`, repository behavior, and page-level integration unchanged unless required by the visual refactor.
- Leave server save/load semantics untouched.

## Test Plan

- Update the existing widget test for `SceneSavedFilterDialog` to keep covering the header save flow.
- Add assertions for the compact Material 3 presentation cues that matter to behavior and structure, for example:
  - the saved presets title
  - the presence of the constrained saved presets section
  - the save action remaining in the header
- Keep tests focused on stable structural behavior, not fragile pixel-level styling details.

## Risks

- Making the sheet too compact could make long preset names or dense metadata harder to scan.
- Over-mirroring the sort panel could hide the difference between "save current settings" and "load saved preset" if the summary and list are not visually separated enough.

## Mitigations

- Keep a distinct current settings summary surface above the presets list.
- Constrain list height instead of truncating the dataset.
- Keep the save action discoverable in the header.

## Acceptance Criteria

- The saved presets panel opens as a compact bottom sheet rather than a near-fullscreen panel.
- The panel visually aligns with the sort panel's Material 3 structure and spacing.
- The current settings summary remains visible and easy to scan.
- The presets list remains scrollable and load behavior is unchanged.
- Saving still requires naming the preset in a dialog and still saves to the server.
- Existing and updated saved presets tests pass.
