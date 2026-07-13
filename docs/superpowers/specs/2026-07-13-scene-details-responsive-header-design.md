# Scene Details Responsive Header Design

## Goal

Improve only the scene-details region from the title through the action buttons so it has clear hierarchy on narrow and wide layouts. Preserve every control, callback, tooltip, and the content below the actions.

## Layout

Use `LayoutBuilder` at `_buildMainInfo` so the decision follows the width allocated to this region.

- Below 720 logical pixels, keep a single column: title, studio/year, metadata chips, rating/O controls, then action icons.
- At 720 logical pixels and above, use a split header: title, studio/year, and metadata on the left; rating/O controls and action icons in a compact right-aligned column.
- Keep the details section below both layouts with the existing spacing.
- Use existing theme spacing and existing button widgets. Do not add a new shared abstraction or visual surface.

## Behavior and Accessibility

All rating, O-counter, marker, info, download, edit, and delete behavior remains unchanged. Existing tooltips, keys, and platform guards remain in place. Wrapping must prevent overflow at narrow widths and under larger text scaling.

## Verification

Add focused widget assertions for narrow and wide viewports, including relative positions of the title and action groups. Run the focused scene-details widget tests and static analysis for the changed files.
