# StashFlow Website Agent Guide

This branch contains only the standalone Vue 3 introduction website.
Application releases and the Flutter web demo live outside this branch.

## Working agreement

- Inspect git status, the owning section in docs/SPECS.md, callers, and nearby
  tests before editing. Preserve unrelated worktree changes.
- Use the current checkout; do not create a worktree without an explicit request.
- Prefer the smallest change using existing helpers and dependencies.
- docs/SPECS.md owns behavior and deployment contracts; DESIGN.md owns the
  website's screenshot-led visual direction.
- Do not edit ignored local tool installations or the stash/ reference checkout.

## Content and accessibility

- Localize visible copy in l10n/site_*.arb. Maintain en, de, es, fr, it, ja, ko,
  ru, zh, zh_Hans, and zh_Hant; keep the zh fallback aligned with zh_Hans.
- Preserve native radios, disclosure navigation, visible focus, reduced motion,
  image proportions, and 44px minimum control targets.
- Keep fonts and images self-hosted under assets/ with their licenses.
- Do not edit generated dist/ output; edit src/App.vue, styles.css, or catalogs.

## Verification

- Install locked dependencies with npm ci.
- Run npm test for catalog coverage, escaped hydration data, static pages, and
  local links/assets; this also performs the production build.
- For UI changes, verify desktop and narrow widths, localized expansion,
  keyboard navigation, contrast, zoom, and static hosting under a subpath.
- For documentation-only edits, check touched paths and git diff --check.
- Report what changed, which checks passed, and any unverified browser or
  deployment risks. Do not imply that an unrun check passed.
