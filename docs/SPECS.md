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
dark primary action. Wide layouts enlarge the device composition and stagger
the filtering/sorting showcases; narrow layouts retain a stacked sequence.
Filtering and sorting copy includes saved defaults.

The plum-black sticky top bar links to mobile and desktop sections, the main
application GitHub repository, and the download section. It keeps every link
visible, with a source-ordered two-column layout on narrow screens, wrapping
localized labels and 44px minimum touch targets. Anchor offsets must accommodate
the localized header height.

CSS-only motion coordinates the hero devices and screenshot changes; supported
browsers also animate the desktop device on scroll. Reduced-motion preferences
remove movement; unsupported browsers retain static content.
[../DESIGN.md](../DESIGN.md) records the visual direction.

## Verification

- `npm test` checks escaped hydration data, builds every locale, validates local
  URLs and asset files, and verifies Chinese fallback equality.
- UI verification covers 320, 390, 768, and 1440px, breakpoint boundaries,
  localized label expansion, keyboard focus, native radios/disclosure, contrast,
  200% zoom, image loading, and JavaScript-disabled navigation.
- Verify refresh and asset loading when served below a hosting subpath.
- Run `git diff --check`; report unverified browsers and remote deployment.
