# Website specification

## Architecture and deployment

This branch contains only the standalone StashFlow introduction website.
Application releases and the Flutter web demo are external destinations;
application code, packaging, and release workflows are not part of this branch.

Vue 3 components use Vite and build-time server rendering. `npm ci` installs
locked dependencies; `npm run build` produces pre-rendered pages in `dist/`.
Vue hydrates each page with its validated ARB copy. Core content, screenshot
radios, and locale navigation remain usable without JavaScript.
Relative asset and locale links must work when hosted at a subpath.

## Content and visual behavior

Copy lives in `l10n/site_*.arb` for en, de, es, fr, it, ja, ko, ru, zh,
zh_Hans, and zh_Hant. Build-time validation rejects missing, extra, or empty
translation keys. The zh fallback stays aligned with zh_Hans.

Mobile and desktop images are shipped in `assets/`. Desktop WebPs retain the
full original captures without cropping or resizing. Device frames preserve
the original image proportions. Variable Manrope is self-hosted with system
fallback for unsupported scripts; asset licenses remain with their files.

The screenshot-matched palette pairs a plum-black hero and orchid display type
with blush-white showcases. The orchid download finale uses plum labels and a
dark primary action. The control section is a full-width plum-black interlude
with orchid display type and larger, unboxed filter/sort screenshots above their
captions. Wide layouts stagger those screenshots; narrow layouts retain a stacked
sequence. Filtering and sorting copy includes saved defaults.

The mobile showcase groups Browse, Play, and Refine as equal-width segments in
one fieldset, using native radio inputs and associated labels. Selected, hover,
and keyboard focus states remain distinct; label weight and segment widths stay
stable when switching. Long localized labels wrap rather than clip. All segments
are at least 48px tall, and selection works without JavaScript. The phone/caption layout preserves full screenshot framing.

The solid plum-black sticky top bar contains home, the main application GitHub
repository, and one download action. It uses a single row with an unboxed GitHub
icon; narrow screens show the brand mark instead of the wordmark, retaining its
accessible name. Duplicate section links are omitted; the hero exploration action
and page scrolling provide access to the mobile/desktop content. Keep 44px minimum
touch targets, visible focus, and anchor offsets that accommodate localized copy.

CSS-only motion stages a bounded hero sequence (at most 920ms): the headline
opens, the laptop turns front-on, and the phone moves into its companion position.
Actions remain immediately usable. Screenshot selection uses a 400ms screen wipe
and 240ms caption fade; rapid selection interrupts the prior panel. Supported
browsers use native scroll timelines to open the desktop device and turn tool
screenshots toward their final, fully framed reading positions. There are no
loops, scroll listeners, motion dependencies, or animated layout dimensions.
Reduced-motion preferences remove movement; unsupported scroll-animation browsers
retain static devices and screenshots.
[../DESIGN.md](../DESIGN.md) records the visual direction.

## Verification

- `npm test` checks escaped hydration data, builds every locale, validates local
  URLs and asset files, and verifies Chinese fallback equality.
- UI verification covers 320, 390, 768, and 1440px, breakpoint boundaries,
  localized label expansion, keyboard focus, native radios/disclosure, contrast,
  200% zoom, image loading, and JavaScript-disabled navigation.
- Verify refresh and asset loading when served below a hosting subpath.
- Run `git diff --check`; report unverified browsers and remote deployment.
