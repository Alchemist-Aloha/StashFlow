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
    fontFamily: "Manrope, system-ui, sans-serif"
    fontSize: "24px"
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: "-0.5px"
  title:
    fontFamily: "Manrope, system-ui, sans-serif"
    fontSize: "20px"
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: "-0.5px"
  body:
    fontFamily: "Manrope, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.43
  label:
    fontFamily: "Manrope, system-ui, sans-serif"
    fontSize: "12px"
    fontWeight: 700
    lineHeight: 1.33
    letterSpacing: "0.4px"
  micro:
    fontFamily: "Manrope, system-ui, sans-serif"
    fontSize: "10px"
    fontWeight: 500
    lineHeight: 1.2
    letterSpacing: "0.3px"
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
    padding: "24px 16px"
  button-outlined:
    textColor: "{colors.on-surface-dark}"
    rounded: "{rounded.md}"
    height: "48px"
    padding: "24px 16px"
  button-text:
    textColor: "{colors.primary-dark}"
    rounded: "{rounded.md}"
    padding: "16px 8px"
  chip-filter:
    backgroundColor: "{colors.surface-container-high-dark}"
    textColor: "{colors.on-surface-dark}"
    rounded: "{rounded.sm}"
    padding: "8px 4px"
  chip-filter-selected:
    backgroundColor: "{colors.primary-container-dark}"
    textColor: "{colors.on-primary-container-dark}"
    rounded: "{rounded.sm}"
    padding: "8px 4px"
  field-filled:
    backgroundColor: "{colors.surface-container-high-dark}"
    textColor: "{colors.on-surface-dark}"
    rounded: "{rounded.md}"
    height: "48px"
    padding: "16px 8px"
  card-scene:
    backgroundColor: "{colors.surface-container-highest-dark}"
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
    size: "32px"
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
    backgroundColor: "{colors.media-scrim}"
    textColor: "{colors.on-surface-dark}"
    rounded: "{rounded.lg}"
    padding: "12px 16px"
---
# Design System: StashFlow

## Overview

**Creative North Star: "The Private Screening Room"**

StashFlow is a material surface laid over a library the user already owns. There is
no storefront to sell, no onboarding story to dramatize: the room should recede so
the artwork can be the event. Chrome is deliberately quiet — app bars carry no
elevation tint (the pinned bar separates with glass and a hairline, not a lift),
cards carry no drop shadow, and the single accent colour appears
only where it carries meaning (a selected filter, the current destination, the one
primary action of a sheet). A StashFlow screen should read as a well-run private
cinema: dark, prepared, nothing on the walls that isn't the film.

Material 3 supplies the motion and state vocabulary (ripples, indicators, container
steps), and the app constrains it hard. The whole system is one user-replaceable
seed colour, one spacing scale multiplied by the user's font-size factor, four
corner radii, and one frosted-glass recipe. Depth is tonal rather than shadowed:
surfaces step from `surfaceContainerHigh` (fields, chips) to
`surfaceContainerHighest` (cards), so a card already reads as lifted at elevation 0.
Because a personal library is browsed at 2 a.m. as often as at a desk, dark and
True Black (AMOLED) are equal citizens, not an inverted filter; the shipped default
is the system setting.

Every dimension that matters is a scaled token, never a literal. Text sizes come
from a ten-step scale, layout values from `spacingSmall` / `spacingMedium` /
`spacingLarge`, and each is multiplied once by `fontSizeFactor`, so the interface
grows as one system when the user scales text.

**Key Characteristics:**
- One seed colour drives every tint. Nothing else in the palette is authored except the True Black steps and the rating amber.
- Depth is tonal at rest: elevation 0 on bars and cards, container steps carry the lift; frosted glass carries whatever overlaps content.
- Cinematic and unfussy: filled actions, borderless fields, shadowless cards, one accent action per surface.
- Everything scales through `fontSizeFactor` — spacing, icon sizes, and every type step together.
- Cards are artwork-first: a full-bleed thumbnail band under a 60% black metadata scrim, with title and studio beneath.
- Frosted glass (`FrostedSurface`) is the depth mechanism for anything that floats over content: the pinned app bar, the mini player, overlay panels, fullscreen image chrome, and player controls. The bottom navigation bar stays flat, because nothing passes behind it.

## Colors

A single seed and its tonal children: the accent the user picks (default **Deep
Harbour Teal**) generates every container, "on" colour, and neutral tint through
Material 3's tonalSpot scheme, so choosing purple or orange shifts the entire room
instead of fighting a fixed brand palette. The neutrals are that same scheme's
near-grey families, lightly tinted by the accent — the reason a teal build feels
cooler than a red one without a single hardcoded surface.

### Primary
- **Deep Harbour Teal** (`#0F766E`): the seed and the only colour the user replaces. It is stored as `app_theme_seed_color` and defaults to teal; every Primary row below is derived from it at runtime by `ColorScheme.fromSeed`. It appears as text and icons where the accent must *speak* (studio names on cards, links, active sort direction) and as fill only for a surface's one primary action.
- **Primary Light / Primary Dark** (`#006A63` / `#81D5CB`): the accent as rendered in each theme. Filled buttons, the focus border of a focused field, selected filter text.
- **Primary Container Light / Dark** (`#9DF2E7` / `#00504A`): the fill behind a selected chip, the selected segment, the mobile navigation bar indicator, and the floating action button. Never used as a large page background.
- **On Primary** (`#FFFFFF` light, `#003733` dark) and **On Primary Container** (`#00504A` / `#9DF2E7`): the only text colours permitted on the fills above.

### Secondary
- **Secondary Container Light / Dark** (`#CCE8E4` / `#324B48`): deliberately narrow. It is the *desktop* navigation rail's selection indicator (the rail overrides the theme's default) and the shape behind secondary emphasis. It is not an alternate accent.

### Neutral
- **Surface Light / Dark** (`#F4FBF8` / `#0E1514`): the scaffold and sheet base, and the tint behind every frosted bar (that colour at 72%). The accent's tint is visible in both, which is why surfaces must never be replaced with pure grey.
- **Surface Container High Light / Dark** (`#E3EAE7` / `#252B2A`): fields, chips, and the frosted panel's body — anything that sits *on* the base surface.
- **Surface Container Highest Light / Dark** (`#DDE4E2` / `#303635`): cards and the standard `Card` theme. This is the top of the tonal ladder in normal themes.
- **On Surface** (`#161D1C` / `#DDE4E2`): body text, titles, and icons.
- **On Surface Variant** (`#3F4947` / `#BEC9C6`): metadata, helper text, empty-state copy, and the description or synopsis prose inside a section panel — 7.2:1 on a card in both themes. A panel's heading is the strong element, so the prose under it is secondary ink; body-strength `onSurface` is for prose that *is* the page's content.
- **Outline / Outline Variant** (`#6F7977` / `#899391`; `#BEC9C6` / `#3F4947`): outlined-button borders, dividers, and the frosted panel's 1px hairline. Outline Variant is decorative only.
- **True Black Surface / Lift / Card** (`#000000` / `#121212` / `#1A1A1A`): the AMOLED overrides applied to `surface`, `surfaceContainerHigh`, and `surfaceContainerHighest`. The tonal ladder survives; only its floor moves to black.
- **True Black Outline / Outline Variant** (`#424242` / `#212121`) and **True Black On Surface Variant** (`#BDBDBD`): the matching borders and secondary ink.
- **Rating Amber Light / Dark** (`#FFA000` / `#FFD54F`): reserved for the star/rating icon and its numeric value. It is the only saturated colour that is not derived from the seed.
- **Error Light / Dark** (`#BA1A1A` / `#FFB4AB`): destructive actions and failure states — the delete action on an edit page, the error state view, and failure text. It never tints a neutral and never appears on a neutral fill; it is the one role that exists to interrupt.
- **Media Scrim** (`rgba(0, 0, 0, 0.6)`): the band behind thumbnail metadata (resolution, performer count, rating, duration) in white.

### Named Rules
**The One Seed Rule.** Exactly one colour is authored by the product. Every other tint — containers, indicators, neutrals, hover overlays — is derived from it. If a new screen "needs" a hardcoded colour, the design is wrong, not the palette.

**The Scrim Rule.** Metadata that sits on artwork is white type on `media-scrim` at 60% black, spanning the full thumbnail width. The scrim is not decoration; it is the contrast mechanism, and it may not be lightened.

**The True Black Exception Rule.** In True Black, surfaces go to black but ink, outlines, and disabled states keep their contrast. Black is a surface value, never a reason to weaken text.

## Typography

**Display Font:** Manrope (bundled under the SIL Open Font License; platform default when the user selects System)
**Body Font:** Manrope — the same family across the whole interface; there is no second voice
**Label/Mono Font:** JetBrains Mono (one of six user-selectable bundled families; used when the user wants technical density, never as an internal accent)

**Character:** Manrope is geometric-humanist and slightly narrow: it holds up at the 10–12px sizes this interface lives at (metadata, counters, timestamps) without turning into a technical readout, and it stays neutral enough that a user who switches to Lora or JetBrains Mono gets a coherent interface rather than a broken one. Type does the hierarchy work here; colour and weight are secondary.

### Hierarchy
- **Display** (700, 24px, 1.25): the top of `context.fontSizes.display`. Detail-page hero titles and empty-state headlines; at most one per screen.
- **Title** (700, 20px, 1.3, −0.5px tracking): page titles in the app bar (`titleLarge`, bold, negative tracking applied by `ListPageScaffold`) and sheet headers (`headlineSmall`, bold). Section headers use `titleMedium` bold at 16px.
- **Body** (400, 14px, 1.43): descriptions, details text, and empty-state copy. `bodySmall` is pinned to 12px so it never collapses below readable metadata size.
- **Label** (700, 12px, 1.33, +0.4px tracking): studio names on cards, sort values, filter summaries, and list metadata — the accent-coloured tier.
- **Micro** (500, 10px, 1.2): the `tiny`–`small` grades (9–11px) for overlay counters and duration on thumbnails, and the `+3` performer overflow. Never for prose.

### Named Rules
**The Scale-Once Rule.** Every size is multiplied by `fontSizeFactor` exactly once, at the theme level. Card titles read `context.dimensions.cardTitleFontSize` directly — multiplying again is a bug, not a nuance.

**The One Family Rule.** A screen uses one type family. Weight, size, and tracking carry hierarchy; mixing families inside a view is not an option the system offers.

## Layout

A three-band responsive shell at 600px and 1200px (`Responsive.mobileBreakpoint` /
`tabletBreakpoint`). Below 600px the shell shows a `NavigationBar` pinned to the
bottom (72px tall, labels always visible) with the mini player as a 66px band
directly above it. At 600px and up, the bar is replaced by a `NavigationRail` with
selected-only labels, separated from the body by a 1px `VerticalDivider`. Above
1200px the content area widens; the grid gains columns rather than growing cells.

Content grids use 8px outer padding, 8px cross-axis spacing, and 16px main-axis
spacing (`GridUtils`), and open at two columns. Grid cells are locked to a 1.15
child aspect ratio for media-plus-caption items; a scene card's thumbnail band is a
forced 16:9 in grid mode, while list and masonry modes respect the source file's
aspect ratio clamped to 0.5–2.5 so portrait clips do not distort. Square source
video on mobile is normalised to 9:16 to avoid a squat thumbnail.

Spacing is a three-step scale — 8 / 16 / 24 (`spacingSmall` / `spacingMedium` /
`spacingLarge`), each multiplied by `fontSizeFactor` — plus a 4px unit for
in-element gaps that is used sparingly. Interactive height is 48px
(`buttonHeight`), also scaled. Density is comfortable, not compact: cards breathe
with 12px internal padding in list mode and 8/4 in grid mode, and the interface
never relies on hairline borders to separate content.

## Elevation & Depth

The system is **tonal first and translucent second**. The bar and the cards sit at
elevation 0 — no drop shadow, no M3 elevation tint; lift is expressed by stepping up
the neutral container ladder
(`surface` → `surfaceContainerHigh` → `surfaceContainerHighest`), so a card reads
as above the page without a shadow.

Translucency handles the other case: a surface that content passes behind. Where
rows, artwork, or video genuinely run underneath, the surface is glass — a
backdrop blur with a translucent tint and a hairline. Every one of them is built
from the single `FrostedSurface` recipe (`AppTheme.frostedBlurSigma`,
`AppTheme.frostedChromeAlpha`, `AppTheme.frostedHairlineAlpha`), so blur, tint,
and edge cannot drift apart between surfaces.

| Surface | Treatment |
| --- | --- |
| Pinned app bar (list pages) | `surface` at 72%, 4px blur, 1px bottom hairline. The list carries the bar height as scroll padding, so artwork passes behind the glass; the M3 scroll lift is switched off — the glass *is* the elevation. |
| Floating action pill over the grid | `surfaceVariant` at 72%, 4px blur, 32px radius, 8px soft shadow. |
| Mini player band | `surface` at 72%, 4px blur, 1px top hairline, 10px soft shadow. The shell publishes its 66px height (`MiniPlayer.height`) as bottom inset, so the last row always scrolls clear of it. |
| Overlay panels (filters, rating, scene info, saved filters, playlist) | `surfaceContainerHigh`, 4px blur, 1px hairline, the one authored `0 8px 24px` shadow. |
| Fullscreen image chrome | Stronger 10–12px blur, because the backdrop is full-bleed photography rather than UI. |
| Video player chrome (seek bubble, time pills, gesture feedback) | A black scrim at 55% with 4px blur, so white player type holds over any frame. The black tint is deliberate: this chrome must read over video, not over the app's own surfaces. |
| Bottom navigation bar | **Deliberately flat opaque.** It owns a Scaffold slot and nothing passes behind it; glass with an empty backdrop is decoration. Use `surface` and the container steps. |
| Cards, fields, chips, sort bars | Flat tonal. They sit in flow and push content instead of overlapping it. |

### Shadow Vocabulary
- **Frosted panel** (`box-shadow: 0 8px 24px` at 40% of the scheme shadow, over `backdrop-filter: blur(4px)`): the one authored panel shadow. Panels that float over content, never inline cards.
- **Floating chrome** (mini player `0 2px 10px` at 10%, action pill `0 4px 8px` at 20%): short, soft, and bottom-biased — enough to separate glass from the artwork behind it, never a bevel.
- **Blur scale**: 4px over app surfaces, 10–12px over photography. Anything else is a new recipe and needs a reason.

### Named Rules
**The Flat-By-Default Rule.** If a surface is at rest and does not float over content, its elevation is 0. Depth is a container step.

**The Frosted-For-Floating Rule.** Anything that overlays content is frosted, and the tint stays translucent enough for the backdrop to read through it: `surfaceContainerHigh` for panels, `surface` or `surfaceVariant` at 72% for chrome. A hand-rolled `BackdropFilter` plus `Container` pair is a regression, and an opaque tint over a blur is a `Container` with a GPU bill.

**The Pass-Behind Rule.** Glass is only earned when content actually travels behind the surface. A surface that pushes content away — the bottom navigation bar, cards in a grid, a sort bar — stays flat and tonal. Blur with an empty backdrop is decoration and is a bug, not a style.

## Shapes

Corners are soft and consistent: **8px** for small elements (chips, filter pills, over-thumbnail badges, the tappable page-title area), **12px** for cards, fields, buttons, and the navigation rail indicator, **16px** for section panels and other large in-flow blocks, and **28px** (the extra-large radius) for the frosted panel and sheet top corners — nothing else in the interface uses 28px. Two geometries sit outside the token ladder deliberately: **full-bleed media chrome** (the fullscreen image bars, the tagger and dedup tool panels) rounds at 20–24px, where a 12px corner would look mean against a photograph, and **pills** (the floating action pill at 32px, player time chips and switch tracks at 999px) are fully rounded because the shape is the affordance. Nothing in the interface is square except the 32px icon-button hit area around a compact `more_vert`.

Borders are rare and intentional. Chips and text fields use `BorderSide.none` and
rely on fill; the only rules in the interface are outlined-button borders, the 1px
rail divider, the frosted hairline (panel border, app-bar bottom edge, mini-player
top edge), and the 2px accent border on a focused field. Thumbnails are full-bleed
and clipped with `Clip.antiAlias` at the card's 12px radius; circles are reserved for
user identity (performer avatars, the colour swatches in Appearance), never for
actions. Media geometry is always a rectangle with a real aspect ratio — the system
does not crop performer faces into shapes.

## Components

Components are **cinematic and unfussy**: controls recede, artwork leads, and a
surface gets one accent action at most.

### Buttons
- **Shape:** rounded 12px (`radiusMedium`) across every variant; no pill buttons in the chrome.
- **Primary (filled):** accent fill with on-accent text, minimum height 48px, horizontal padding 24px / vertical 16px. Used for a sheet's single commit action ("Save", "Apply"), and rendered as `ElevatedButton` repainted to `primary` inside panel actions so it stands above the frosted body.
- **Outlined:** 1px `outline` border on transparent fill, same 48px height and 24/16 padding. The alternate action beside a filled one.
- **Text:** accent-tinted label, 12px radius, 16/8 padding, with a ripple bounded by the radius. This is the "Reset" and "View all" affordance — used freely in headers, sparingly in bodies.
- **Floating action button:** `primaryContainer` fill with `onPrimaryContainer` icon. One per screen, only for the screen's defining creation action.
- **Segmented button:** selected segment takes `primaryContainer` / `onPrimaryContainer` with 8/4 padding — the compact multi-choice control for grid/list and sort direction.

### Chips
- **Style:** 8px radius, `surfaceContainerHigh` fill, no border at all (`BorderSide.none`). A chip is a small tile, not an outline.
- **State:** unselected chips carry `onSurface` at label size; selection swaps to `primaryContainer` / `onPrimaryContainer` and stays the same shape and size, so selection changes colour, never geometry. `chipTheme` owns that pair for every chip family, so a filter panel must not restate it. Dismissible criterion chips inside filter sheets keep the chip's own delete affordance and text-scale with everything else.
- **Over-thumbnail badges** (rating, image count, marker range) are the exception to the chip fill: they sit on artwork, so they use `media-scrim` at 60% with `ratingColor` for the star and the 8px small radius. The gallery, image, and marker cards share one recipe; a badge is never restyled on its own.

### Cards / Containers
- **Corner Style:** 12px for media cards, clipped with `Clip.antiAlias` so artwork cannot square the corners; 16px for a section panel.
- **Background:** scene and media cards use the accent container at 30% opacity over the base surface — a barely-there tint that lets a wall of thumbnails stay calm. A section panel is `surfaceContainerHighest` flat, with no tint and no alpha. The generic `Card` theme uses `surfaceContainerHighest` at elevation 0.
- **Shadow Strategy:** none; see Elevation & Depth. Depth comes from the container step and the thumbnail's own contrast.
- **Border:** none. Cards are never outlined.
- **Internal Padding:** 12px all round in list mode; 8px horizontal / 4px vertical under a grid thumbnail; 4px/2px for the metadata overlay band; `spacingMedium` inside a section panel.
- **Composition:** a full-bleed thumbnail band (16:9 in grid, source ratio clamped 0.5–2.5 in list), a `media-scrim` metadata strip at its bottom edge (white micro/label type, 10px or 12px icons), then title (bold, `cardTitleFontSize`, max 2 lines, ellipsised), studio·year in accent label, and an optional performer avatar row with a `+N` overflow.

### Section Panel
One recipe, declared once, for content grouped *inside* a page: a detail page's controls and metadata, a sheet's info block, a settings group. `SectionPanel` supplies the `surfaceContainerHighest` fill, the 16px radius, `spacingMedium` padding, an optional bold `titleMedium` heading in `onSurface` with an optional trailing action, and an optional whole-panel tap target.

A panel is never tinted with the accent and never carries a shadow or a border — it is a quiet neutral block whose lift is the container step. Its heading uses the same voice as a standalone section header, so the two cannot drift apart. A caller supplies content, a title, and a trailing action; it does not supply styling, and it must not re-implement the recipe locally.

### Inputs / Fields
- **Style:** filled with `surfaceContainerHigh`, no border, 12px radius, content padding 16px / 8px. Search lives in a `SearchAnchor` view rather than an inline expanding field.
- **Focus:** the resting borderless field gains a 2px accent border (`primary`) and nothing else — no glow, no shadow, no fill change.
- **Error / Disabled:** the system adds no authored error styling; it inherits Material's `error` treatment, which is why error text must remain legible on `surfaceContainerHigh` in both themes and under True Black.

### Navigation
- **Mobile:** bottom `NavigationBar`, 72px tall, labels always shown, `primaryContainer` indicator behind the selected destination; unselected icons use `onSurfaceVariant`, selected use `onPrimaryContainer`.
- **Desktop / tablet:** `NavigationRail` with selected-only labels and a `secondaryContainer` indicator at 12px radius with `onSecondaryContainer` icons, plus a 1px vertical divider against the body. The rail deliberately uses the secondary container while the bar uses the primary container — the two are not interchangeable, and `navigationRailTheme` owns both the colour and the shape.
- **App bar:** frosted glass over `surface` at 72% with a 1px bottom `outlineVariant` hairline, and no scroll lift — the glass *is* the elevation. Left-aligned bold title with −0.5px tracking; actions are icon buttons (sort, filter, refresh-on-desktop) each with a tooltip, and search opens the anchor view. The list below carries the bar height as scroll padding, so artwork travels behind the glass. Re-tapping the active destination scrolls its list to top rather than pushing a route.
- **Plain app bar (detail, edit, settings, tool pages):** flat `surface`, elevation 0, **no** scroll-under tint, and the same bold −0.5px-tracked `titleLarge` as the frosted list header. `appBarTheme` owns that title style, so a page must not restate it. Only the list header is frosted; a page that pushes its content instead of letting it travel behind the bar stays flat.
- **Mini player:** a 66px frosted band above the navigation bar (`MiniPlayer.height`), `surface` at 72% with a 1px top hairline and a 10px soft shadow. The shell publishes its height as a bottom inset, so rows run behind the band while the last row still scrolls clear of it.

### Frosted Surface (signature)
One recipe, declared once. `FrostedSurface` clips its own bounds, blurs the backdrop
(`AppTheme.frostedBlurSigma`, 4px), fills with a translucent tint, and closes with a
1px hairline; the caller supplies only the tint and the corner. `FrostedPanel` wraps a
transparent modal sheet in it — `surfaceContainerHigh` body, the extra-large 28px
radius, the system's only shadow — and caps at 88% of viewport height to host
filters, sort, rating, scene info, and saved-filter dialogs. Its composition is
fixed: bold `headlineSmall` header with an optional "Reset" text button, scrolling
body, and a full-width filled action with a text-button dismiss below it.

The same widget carries the pinned app bar, the mini-player band, the floating action
pill over the grid, and the video player's seek bubble, time chips, and gesture
bubble — the player's instances tint black rather than `surface`, because they read
over footage rather than over the app. Because every one of them is translucent, its
contents must stay legible over any artwork behind it: this is the reason the blur
exists, and why a frosted surface only ships where content actually passes behind it.

## Do's and Don'ts

### Do:
- **Do** express depth with container steps (`surfaceContainerHigh` → `surfaceContainerHighest`) and keep elevation at 0 unless a surface genuinely floats.
- **Do** use `context.dimensions.spacingSmall` / `spacingMedium` / `spacingLarge` for every gap and pad, `buttonHeight` for interactive height, and multiply manual icon sizes by `fontSizeFactor`.
- **Do** keep one accent action per surface. The accent is a signal, not decoration — when everything is teal, nothing is.
- **Do** verify light, dark, and True Black for every new surface: measured pairs in this system range from 5.0:1 (`primary` on a card, light) to 17.4:1 (`onSurface` on a True Black card).
- **Do** keep the thumbnail scrim at 60% black and full-width; it is the only thing making white metadata legible over arbitrary artwork.
- **Do** route every new floating or overlay surface through `FrostedSurface` (`FrostedPanel` for overlay panels), and give it a backdrop that actually passes behind it.
- **Do** keep frosted tints translucent (`AppTheme.frostedChromeAlpha`, 72%) so the backdrop reads through the glass, and let the blur carry the legibility instead of darkening the tint. Measured worst case (a pure white thumbnail behind a dark-theme header) is 5.7:1 for the bar title; 0.82 would buy 8.3:1 and hide the blur.
- **Do** keep blocks and containers on the four radius tokens (8 / 12 / 16 / 28) and gaps on the three-step spacing scale; only pills and full-bleed media chrome leave the ladder, and only for the reasons in Shapes.
- **Do** group in-page content with `SectionPanel` and head it with `SectionHeader` (or the panel's own `title`); both read their colour, radius, and heading style from the system, so a grouped block looks the same on a detail page, in a sheet, and in settings.

### Don't:
- **Don't** hardcode a colour. Every tint derives from the seed; the only sanctioned literals are the True Black steps (`#000000`, `#121212`, `#1A1A1A`, `#424242`, `#212121`, `#BDBDBD`) and the rating amber.
- **Don't** hand-roll a grouped block. A local `Card`/`Container` carrying its own fill, radius, border, and title style is the drift this system exists to prevent; the theme-level recipe and `SectionPanel` are the only places that decide those values.
- **Don't** restate a token the theme already supplies at the call site — chip fill and selection, app-bar title style, or a panel's surface. A redundant override is how two identical surfaces silently drift apart.
- **Don't** signal a status with a hue outside the palette. There is no green: a good or reachable state uses `primary` (icon and value) or `secondaryContainer` / `onSecondaryContainer` (a banner), and `error` remains the only role that interrupts.
- **Don't** add shadows to cards, app bars, list rows, or inline headers. The frosted app bar separates with a hairline, not a shadow.
- **Don't** frost a surface that content never travels behind (the bottom navigation bar, cards in a grid): `BackdropFilter` with an empty backdrop costs GPU for nothing.
- **Don't** hand-roll `BackdropFilter` + `Container` when `FrostedSurface` exists, and don't change the blur per screen without a photography-backed reason.
- **Don't** use the rating amber as text. On light surfaces `#FFA000` measures 1.94:1 against `surface` and 1.67:1 on a field fill — it is an icon-and-value colour, always paired with a visible label.
- **Don't** rely on True Black separators to carry state or meaning: `#424242` on black is 2.09:1 and `#212121` is lower still. They are decorative hairlines.
- **Don't** add borders to chips or text fields — the filled treatment is the norm and the focus border is the only authored edge.
- **Don't** mix the navigation indicators: the bar uses `primaryContainer`, the rail uses `secondaryContainer`.
- **Don't** multiply a token by `fontSizeFactor` a second time, and don't introduce a static `AppTheme` dimension constant for layout.