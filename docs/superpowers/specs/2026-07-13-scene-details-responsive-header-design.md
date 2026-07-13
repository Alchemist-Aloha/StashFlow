# Scene Details Responsive Header Design

## Goal

Refine only the scene-details region from the title through the action buttons. The result should feel deliberate and premium on mobile and large screens without changing any control, callback, tooltip, platform guard, or content below the actions.

## Visual Direction

Use a **Soft Structuralist vertical hierarchy**: strong title typography followed by controls and compact technical metadata.

- Use semantic colors from the existing Material 3 theme so light, dark, and custom color schemes remain correct.
- Keep the title and Studio/Year identity block directly on the page background.
- Wrap only the control group and metadata chips in the existing section container so their rectangle uses the exact color, radius, padding, and margin used by Details.
- Do not add a nested control surface, border, or shadow.
- Do not use gradients, backdrop blur, grain, or decorative animation in this scrolling region.
- Keep the existing outlined icon glyphs and dependencies, but normalize the action icons to a precise visual size and consistent tonal treatment.

## Responsive Composition

Use `LayoutBuilder` at `_buildMainInfo`; the breakpoint follows the width allocated to the content, not the device type or orientation.

### Mobile: below 768 logical pixels

Use a full-width vertical composition:

1. Title.
2. Studio and year, 6 logical pixels below the title.
3. Rating/O and action controls, 16 logical pixels below the studio line.
4. Technical metadata chips, 16 logical pixels below the controls.

Below the outside identity block, stack rating/O and the five scene actions as two wrapping rows inside the shared section rectangle. Metadata chips follow inside the same rectangle. Use an 8-pixel rhythm and allow either row to wrap under text scaling. Nothing may scroll horizontally.

On tablet and desktop widths where both groups fit, place rating/O and all scene actions on one line. Rating/O stays left; the action group is pinned to the right edge. Use one responsive `Wrap` so the actions fall back below only when required to preserve 48-pixel touch targets.

### Large screen: 768 logical pixels and above

Use the same identity → controls → metadata order as mobile. Keep the larger title typography and the single-line control composition whenever both control groups fit.

The title must retain the dominant width. Long titles wrap naturally instead of compressing or pushing controls off-screen. The Details card remains full-width below the header card using the shared section margin.

## Typography and Rhythm

- Mobile title: existing `headlineSmall`, weight 700, slightly tightened letter spacing.
- Large title: existing `headlineMedium`, weight 700, slightly tightened letter spacing.
- Studio/year: existing theme typography with studio as the primary link and year at reduced emphasis.
- Metadata: retain the existing compact chips, using 6-pixel spacing and run spacing.
- Shared section padding: use the existing `AppTheme.spacingMedium` value without another control wrapper.
- Maintain a 48×48 logical-pixel minimum hit area for every icon action, including rating stars. Visual icons may remain smaller inside those targets.

Do not introduce a font package or modify the global theme for this isolated region.

## Interaction and Accessibility

All rating, O-counter, marker, info, download, edit, and delete behavior remains unchanged. Preserve existing keys, tooltips, semantics, focus behavior, ordering, and the non-web download guard.

Use native Material state layers for hover, focus, press, and disabled feedback. Do not add entrance or breakpoint animations: this header lives inside a scrolling page, and layout motion would add noise without clarifying state.

The layout must remain overflow-free at narrow widths and at 1.5× text scaling. Touch targets must not overlap when either control row wraps.

## Scope

Modify only `scene_details_page.dart` and its focused scene-details widget test. Reuse existing theme values and button widgets. Add no dependency, shared abstraction, global theme change, player change, or details-section redesign.

## Verification

Add stable keys for the identity and control groups, then verify:

- Mobile: identity is above the control group and both use the available width without overflow.
- Large screen: controls remain below the identity block and above metadata.
- Tablet/desktop controls: rating/O and actions share a line, with actions aligned right.
- Surface parity: the controls/metadata and Details cards use the exact same section-container color while title and Studio/Year remain outside.
- Text scaling: the mobile layout at 1.5× produces no overflow exceptions.
- Existing scene action, rating, O-counter, safe-area, and navigation tests continue to pass.

Run the focused scene-details widget tests and static analysis for the two changed Dart files.
