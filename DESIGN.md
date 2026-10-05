---
name: "StashFlow"
description: "The Private Screening Room — a Material 3 client for a self-hosted Stash media library."
colors:
  teal-seed: "#0F766E"
  primary-light: "#006A63"
  primary-dark: "#81D5CB"
  on-primary-light: "#FFFFFF"
  on-primary-dark: "#003733"
  primary-container-light: "#9DF2E7"
  primary-container-dark: "#00504A"
  on-primary-container-light: "#00504A"
  on-primary-container-dark: "#9DF2E7"
  secondary-container-light: "#CCE8E4"
  secondary-container-dark: "#324B48"
  surface-light: "#F4FBF8"
  surface-dark: "#0E1514"
  surface-container-high-light: "#E3EAE7"
  surface-container-high-dark: "#252B2A"
  surface-container-highest-light: "#DDE4E2"
  surface-container-highest-dark: "#303635"
  on-surface-light: "#161D1C"
  on-surface-dark: "#DDE4E2"
  on-surface-variant-light: "#3F4947"
  on-surface-variant-dark: "#BEC9C6"
  outline-light: "#6F7977"
  outline-dark: "#899391"
  outline-variant-light: "#BEC9C6"
  outline-variant-dark: "#3F4947"
  error-light: "#BA1A1A"
  error-dark: "#FFB4AB"
  true-black-surface: "#000000"
  true-black-lift: "#121212"
  true-black-card: "#1A1A1A"
  true-black-outline: "#424242"
  true-black-outline-variant: "#212121"
  true-black-on-surface-variant: "#BDBDBD"
  rating-amber-light: "#FFA000"
  rating-amber-dark: "#FFD54F"
  accent-preset-blue: "#2196F3"
  accent-preset-purple: "#9C27B0"
  accent-preset-orange: "#FF9800"
  accent-preset-red: "#F44336"
  accent-preset-green: "#4CAF50"
  media-scrim: "rgba(0, 0, 0, 0.6)"
typography:
  display:
    fontFamily: "system-ui, sans-serif"
    fontSize: "24px"
  title:
    fontFamily: "system-ui, sans-serif"
    fontSize: "22px"
    fontWeight: 700
    lineHeight: 1.27
    letterSpacing: "-0.5px"
  body:
    fontFamily: "system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.43
  label:
    fontFamily: "system-ui, sans-serif"
    fontSize: "12px"
    fontWeight: 500
    lineHeight: 1.33
    letterSpacing: "0.5px"
  micro:
    fontFamily: "system-ui, sans-serif"
    fontSize: "10px"
rounded:
  none: "0px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "28px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
components:
  button-filled:
    backgroundColor: "{colors.primary-dark}"
    textColor: "{colors.on-primary-dark}"
    rounded: "{rounded.md}"
    height: "48px"
    padding: "16px 24px"
  button-outlined:
    textColor: "{colors.on-surface-dark}"
    rounded: "{rounded.md}"
    height: "48px"
    padding: "16px 24px"
  button-text:
    textColor: "{colors.primary-dark}"
    rounded: "{rounded.md}"
    padding: "8px 16px"
  chip-filter:
    backgroundColor: "{colors.surface-container-high-dark}"
    textColor: "{colors.on-surface-dark}"
    rounded: "{rounded.sm}"
  chip-filter-selected:
    backgroundColor: "{colors.primary-container-dark}"
    textColor: "{colors.on-primary-container-dark}"
    rounded: "{rounded.sm}"
  field-filled:
    backgroundColor: "{colors.surface-container-high-dark}"
    textColor: "{colors.on-surface-dark}"
    rounded: "{rounded.md}"
    padding: "8px 16px"
  card-scene:
    backgroundColor: "rgba(0, 80, 74, 0.3)"
    rounded: "{rounded.md}"
  panel-section:
    backgroundColor: "{colors.surface-container-highest-dark}"
    rounded: "{rounded.lg}"
    padding: "16px"
  nav-bar-indicator:
    backgroundColor: "{colors.primary-container-dark}"
    rounded: "{rounded.xl}"
    size: "64px 32px"
  nav-rail-indicator:
    backgroundColor: "{colors.secondary-container-dark}"
    rounded: "{rounded.md}"
  panel-frosted:
    backgroundColor: "{colors.surface-container-high-dark}"
    rounded: "{rounded.xl}"
  chrome-app-bar-frosted:
    backgroundColor: "{colors.surface-dark}"
    rounded: "{rounded.none}"
    height: "56px"
    width: "100%"
  chrome-mini-player:
    backgroundColor: "{colors.surface-dark}"
    rounded: "{rounded.none}"
    height: "66px"
    width: "100%"
  chrome-player-chip:
    backgroundColor: "rgba(0, 0, 0, 0.55)"
    textColor: "{colors.on-primary-light}"
    rounded: "{rounded.lg}"
    padding: "12px 16px"
---
# Design System: StashFlow

## Overview

**Creative North Star: "The Private Screening Room"**

Preserve the quiet, artwork-first Material 3 interface: the library is the event,
and chrome should help users browse and operate it without competing with media.
“The Private Screening Room” describes the incumbent visual direction, not a
requirement to force dark mode or a particular font.

Depth is tonal for in-flow content. Translucent chrome separates overlapping
content with shared blur and hairlines; opaque overlay panels retain their
rounded shape and shadow without performing an invisible blur. Light, dark,
and True Black are supported appearances, with System as the default theme mode.

**Key Characteristics:**
- One user-replaceable seed generates the Material color scheme.
- Shadowless media cards put artwork before chrome.
- Shared spacing and type scales follow the global UI size factor.
- System is the default font; user-selected families apply throughout the UI.
- Translucent bars and media overlays use the shared `FrostedSurface` recipe.
- In-page groups use neutral `SectionPanel` blocks and consistent headings.

This document describes current code, not a redesign. The frontmatter is a
portable baseline snapshot at scale 1 with the default teal seed. Component
color examples use normal dark mode unless stated otherwise; they are not
fixed application colors. Runtime roles and user preferences remain authoritative.
Flutter dimensions are logical pixels; CSS pixels in the sidecar are preview
translations, not native layout instructions.

Sources: [product context](PRODUCT.md), [current contracts](docs/SPECS.md),
[theme](lib/core/presentation/theme/app_theme.dart),
[font preference](lib/core/presentation/theme/font_family_provider.dart).
Committed screenshots under `asset/` are historical visual evidence; their
purple accent and earlier chrome do not override the current theme and widgets.

## Colors

**Deep Harbour Teal** is the default seed. Material's `ColorScheme.fromSeed`
generates the palette at runtime; changing the seed changes containers and
near-neutral surfaces as well as the accent.

### Primary
- **Deep Harbour Teal** (`teal-seed`): default seed, persisted through the theme-color preference.
- **Primary / On Primary**: filled actions, interactive emphasis, and focused-field borders.
- **Primary Container / On Primary Container**: selected chips and segments,
  mobile navigation indicators, and FABs.
- **Accent presets**: blue, purple, orange, red, and green are alternative seed
  choices, not simultaneous status colors.

### Secondary
- **Secondary Container**: the navigation rail selection indicator.
  Its foreground is runtime `onSecondaryContainer`; do not substitute the
  mobile bar's primary-container pair.

### Neutral
- **Surface**: scaffold base and translucent app-bar/mini-player tint.
- **Surface Container High**: fields, chips, and the opaque overlay-panel body.
- **Surface Container Highest**: generic cards and in-flow section panels.
  Media cards instead use `primaryContainer` at 30% alpha.
- **On Surface**: primary text and icons. **On Surface Variant**: supporting
  metadata and secondary prose.
- **Outline / Outline Variant**: outlined-button borders, dividers, and
  decorative glass hairlines.
- **True Black steps**: black base surfaces, subtle lift, and card lift;
  `onSurface` becomes white, while secondary ink and outlines use explicit
  True Black overrides. Accent roles remain seed-derived.
- **Rating Amber**: rating icons and numeric values, paired with a readable label.
- **Error**: destructive actions and failures; use Material's semantic role.
- **Media Scrim**: black at 60% behind white thumbnail metadata.
  Video-player floating chrome uses a separate 55% black tint.

### Named Rules
**The One Seed Rule.** Derive ordinary UI colors from the user's seed through semantic roles. True Black overrides, rating amber, and black/white media treatments are deliberate exceptions.

**The Scrim Rule.** Keep thumbnail metadata legible over arbitrary artwork with the shared black scrim and white foreground.

**The True Black Exception Rule.** Changing the surface floor to black must not weaken text, disabled-state, or overlay contrast.

## Typography

**Display / Body / Label Font:** platform System by default. Appearance also
offers Serif, Monospace, Manrope, Outfit, Space Grotesk, Inter, Lora, and
JetBrains Mono. The six named families are bundled; missing glyphs fall back
to platform fonts. JetBrains Mono is a whole-interface choice, not a separate
metadata accent.

**Character:** hierarchy comes from Material roles, deliberate weight changes,
and the user's chosen family. Manrope remains an available geometric-humanist
option, not the shipped default.

### Hierarchy
- **Material text roles:** `Typography.material2021` supplies Display, Headline,
  Title, Body, and Label styles; the theme scales their font sizes.
- **App-bar title:** `titleLarge` (baseline 22 logical px), bold with −0.5
  tracking. List headers use that larger role unless explicitly overridden.
- **Sheet heading:** `headlineSmall` (baseline 24 logical px), bold.
- **Section heading:** `titleMedium` (baseline 16 logical px), bold.
- **Body:** `bodyMedium` (baseline 14 logical px); `bodySmall` is pinned to 12.
- **Label:** `labelMedium` is pinned to 12; chips use `labelLarge`.
  The frontmatter label sample is `labelMedium`, not a universal chip style.
- **Custom `FontSizes` extension:** tiny 9, xSmall 10, small 11, regular 12,
  medium 13, body 14, large 16, xLarge 18, title 20, display 24.
  These are size helpers, not replacements for the Material hierarchy.
- **Card title:** configurable, baseline 12; performer avatar size defaults to 16.
  Both arrive already scaled through `AppDimensions`.

The frontmatter `display` and `micro` entries represent custom size helpers;
they intentionally do not prescribe a weight or line height.

### Named Rules
**The Scale-Once Rule.** Consume scaled theme dimensions and text roles directly. Multiply manual icon sizes once by `fontSizeFactor`; never scale a card-title token twice.

**The One Family Rule.** Apply the user's selected family consistently; use size and weight rather than an extra decorative typeface.

## Layout

[Responsive](lib/core/utils/responsive.dart) defines mobile below 600 logical px,
tablet from 600 to below 1200, and desktop at 1200 and above. The shell uses a
72-high bottom navigation bar on mobile and a selected-label navigation rail
on wider layouts. The mini-player band is 66 high.

[GridUtils](lib/core/presentation/widgets/grid_utils.dart) supplies scaled
small outer padding and cross-axis gaps, medium main-axis gaps, two columns
by default, and a 1.15 item aspect ratio. Pages may choose masonry, list mode,
or user-configured columns. Scene grid thumbnails use 16:9; list thumbnail
ratios are clamped to 0.5–2.5. Square source video has a mobile 9:16 treatment.

The shared spacing ladder is small / medium / large (8 / 16 / 24 at scale 1),
with half-small gaps where needed. Buttons have a scaled 48 minimum height.
Radii, breakpoints, and the mini-player band are not globally scaled tokens;
do not claim that every literal in the incumbent implementation scales.

Floating chrome must reserve scroll clearance. The shell publishes the
mini-player inset in both bottom `padding` and `viewPadding`; floating actions
and sheets clear it without restoring system padding already consumed by
navigation. Layout must remain usable as `appGlobalScaleProvider` changes.

## Elevation & Depth

**Tonal first; translucency only when visible.** Cards and ordinary app bars
have elevation 0. Plain bars also disable scroll-under lift and surface tint.

| Surface | Current treatment |
| --- | --- |
| List app bar | Surface at 72%, 4 blur, bottom hairline; content scrolls behind it. |
| Mini player | Surface at 72%, 4 blur, top hairline, soft shadow. |
| Floating list-action pill | Surface Container High at 72%, 4 blur, radius 32, soft shadow. |
| Overlay `FrostedPanel` | Opaque Surface Container High, radius 28, hairline and shadow; **no backdrop blur**. |
| Fullscreen image chrome | Translucent media-backed treatment with stronger local blur. |
| Video-player bubbles and time chips | Black at 55%, shared blur, white text. |
| Bottom navigation, fields, chips, in-flow panels | Opaque tonal surfaces, no decorative blur. |

### Shadow Vocabulary
- **Overlay panel:** offset (0, 8), blur 24, scheme shadow at 40%.
- **Mini-player band:** offset (0, 2), blur 10, scheme shadow at 10%.
- **Action pill:** offset (0, 4), blur 8, scheme shadow at 20%.

[FrostedSurface](lib/core/presentation/widgets/frosted_surface.dart) clips the
surface, keeps shadows outside the clip, and inserts a backdrop filter only
when tint alpha is below 1 and blur sigma is above 0. The shared chrome sigma
is 4, tint alpha 0.72, and hairline alpha 0.5. These are separate controls.

### Named Rules
**The Flat-By-Default Rule.** In-flow containers separate through tonal surfaces rather than added shadows.

**The Visible-Blur Rule.** Opaque fills skip backdrop filtering while retaining their clipping, border, shadow, and layout.

**The Pass-Behind Rule.** Use translucent blur where content actually passes behind the surface; do not frost an empty backdrop.

## Shapes

The shared corner ladder is small 8, medium 12, large 16, extra-large 28.
Chips use small corners; cards, fields, buttons, and the rail indicator use
medium; section panels use large; overlay panels use extra-large.

Full-bleed bars may be square-edged. Media chrome has context-specific rounded
forms, and the floating action pill and time chips intentionally leave the
ladder for pill geometry. Performer avatars and appearance swatches are circular.

Filled chips and resting inputs are borderless. Focused inputs gain a 2-wide
primary edge; outlined buttons, rail dividers, and overlay hairlines retain
their purposeful borders. Media cards clip artwork with anti-aliasing.

## Components

### Buttons
Filled and outlined variants share medium corners, scaled minimum height,
and medium vertical / large horizontal padding. Text buttons use small
vertical / medium horizontal padding. Frontmatter padding is CSS order:
vertical first, horizontal second.

Material owns hover, focus, pressed, and disabled states; keep its state layers
and ripple behavior. Do not replace these with brightness filters. Overlay
commit actions use `ElevatedButton` repainted primary/onPrimary through
`BottomSheetPanelActions`; that is distinct from the themed `FilledButton`.

### Chips
Unselected chips use Surface Container High with On Surface labels.
Selection changes to Primary Container and On Primary Container without
changing geometry. `chipTheme` owns the colors, shape, and borderless treatment;
do not restate them per sheet. Material owns chip padding unless a caller
specifies it; frontmatter samples do not establish a new global chip-padding token.

### Cards / Containers
Media cards are artwork-first: medium clipped corners, Primary Container
at 30% alpha, no shadow, thumbnail scrim, configurable bold title, and
optional metadata/avatar rows. Generic `Card` uses opaque Surface Container
Highest at elevation 0; it is not the media-card fill recipe.

### Section Panel
[SectionPanel](lib/core/presentation/widgets/section_panel.dart) owns the neutral
Surface Container Highest fill, large corners, default medium padding,
optional bold Title Medium heading and trailing action, and optional whole-panel
tap ripple. [SectionHeader](lib/core/presentation/widgets/section_header.dart)
uses the same heading voice. Callers may supply padding and margin, not a
second local visual recipe.

### Inputs / Fields
Filled Surface Container High, medium corners, no resting border, medium
horizontal / small vertical padding. Focus adds a 2-wide primary border.
Errors and disabled states inherit Material. Field height depends on content
and text scaling; the theme does not impose a fixed 48-high field.

### Navigation
Mobile: 72-high NavigationBar, labels visible, primary-container selection.
Wider layouts: NavigationRail, selected-only labels, secondary-container
selection, medium indicator corners, and a vertical divider.

List headers are translucent; plain detail/settings/tool bars are flat.
Performer, studio, tag, and gallery details omit the app-bar title so identity
lives in content. Entity view-all grids use the owning entity name; search-only
headers leave sort and filter controls in the bottom action pill.
These title/action policies are owned by [the specification](docs/SPECS.md).

### Overlay Panel and Floating Chrome
[FrostedPanel](lib/core/presentation/widgets/bottom_sheet_panel_chrome.dart)
uses the shared surface widget with an **opaque** fill: rounded panel, hairline,
shadow, no blur. Header and actions are separate composition helpers, not
mandatory children enforced by the panel itself. Many sheets cap height at
88% of the viewport, but that cap belongs to callers rather than the primitive.

App bars, mini player, action pills, and translucent media chrome use the
same `FrostedSurface` with context-appropriate tint, corners, and optional
border/shadow. Opaque panels and translucent chrome must not be conflated.

## Do's and Don'ts

### Do:
- **Do** use semantic runtime colors; check light, dark, True Black, and alternative seeds.
- **Do** use scaled dimensions and text roles, and verify supported scale extremes.
- **Do** reuse SectionPanel and SectionHeader for in-page grouping.
- **Do** preserve Material keyboard focus, state layers, semantics, and localized labels.
- **Do** reserve scroll and safe-area clearance for floating chrome.
- **Do** keep artwork metadata readable with the shared scrim.
- **Do** keep the existing quiet visual direction while honoring user appearance preferences.

### Don't:
- **Don't** treat the baseline teal/dark preview values as fixed application colors.
- **Don't** present Manrope as the default or mix selected font families within a view.
- **Don't** multiply already scaled dimensions by the global factor again.
- **Don't** add shadows or borders to media cards to manufacture depth.
- **Don't** blur an opaque surface or a surface with no visible backdrop.
- **Don't** rebuild FrostedSurface or SectionPanel styling at individual call sites.
- **Don't** use amber alone to communicate meaning; pair rating color with readable labels.
- **Don't** rely on decorative hairlines as the sole indicator of state.
