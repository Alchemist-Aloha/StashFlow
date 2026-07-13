# Scene Details Responsive Header Design

## Goal

Refine only the scene-details region from the title through the action buttons. The result should feel deliberate and premium on mobile and large screens without changing any control, callback, tooltip, platform guard, or content below the actions.

## Visual Direction

Use a **Soft Structuralist Editorial Split**: generous negative space and strong type on the left, with a compact control group on the right.

- Use semantic colors from the existing Material 3 theme so light, dark, and custom color schemes remain correct.
- Wrap the full title-through-actions region in the existing section container so it is one rounded rectangle with the exact color, radius, padding, and margin used by Details.
- Keep the control group on that shared background; do not add a nested control surface, border, or shadow.
- Do not use gradients, backdrop blur, grain, or decorative animation in this scrolling region.
- Keep the existing outlined icon glyphs and dependencies, but normalize the action icons to a precise visual size and consistent tonal treatment.

## Responsive Composition

Use `LayoutBuilder` at `_buildMainInfo`; the breakpoint follows the width allocated to the content, not the device type or orientation.

### Mobile: below 768 logical pixels

Use a full-width vertical composition:

1. Title.
2. Studio and year, 6 logical pixels below the title.
3. Technical metadata chips, 16 logical pixels below the studio line.
4. Control group, 20 logical pixels below the metadata.

Inside the shared section rectangle, place rating and O-counter controls in the first wrapping row and the five scene actions in a second wrapping row. Use an 8-pixel rhythm and allow either row to wrap under text scaling. Nothing may scroll horizontally.

### Large screen: 768 logical pixels and above

Use an editorial split aligned at the top:

- Left: an `Expanded` identity block containing title, studio/year, and technical metadata.
- Gap: 32 logical pixels.
- Right: a 304–344 logical-pixel control group containing the same two control rows, right-aligned.

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
- Large screen: identity and control group share a top row, with controls positioned to the right.
- Surface parity: the header and Details cards use the exact same section-container color.
- Text scaling: the mobile layout at 1.5× produces no overflow exceptions.
- Existing scene action, rating, O-counter, safe-area, and navigation tests continue to pass.

Run the focused scene-details widget tests and static analysis for the two changed Dart files.
