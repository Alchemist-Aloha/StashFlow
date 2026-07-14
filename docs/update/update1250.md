# StashFlow v1.25.0

## ✨ New Features

### Random Navigation

- Added random navigation for scenes, galleries, performers, studios, and tags.
- Scene random navigation can optionally respect the active search and filter state through a new Interface setting.
- Random scene actions are available from scene lists, details, and fullscreen playback without replacing the main playback queue.

### Playlist Panel

- Added paged playlist loading for video playback.
- Added a floating playlist panel to inspect and navigate the current playback queue.

## 🎨 UI & UX Improvements

- Settings hub and detail pages now share consistent spacing, section headers, panel surfaces, loading states, and empty states.
- Bottom sheets, saved-filter dialogs, sort sheets, stats panels, and related overlays now use the shared frosted-panel presentation.
- Scene details now use a responsive header that keeps identity, metadata, and actions readable across wide and narrow layouts.
- Scene technical metadata now appears below Studio and Year, is hidden by default, and can be revealed with a muted trailing `Show metadata` action.
- Added an Interface setting to show scene metadata by default; the scene header now keeps Studio, Year, and the reveal action aligned without an underline on the Studio link.
- Tightened the hidden-metadata header spacing to match the Title-to-identity rhythm and preserved narrow-screen overflow handling.
- Updated scene header controls and fullscreen playback controls, including random navigation access.

## 🛡️ Playback & Stability

- Android media notifications now stay synchronized with playback state and are dismissed when playback ends.
- Playback completion callbacks are edge-triggered to prevent duplicate queue advancement.
- Artwork updates are guarded against stale media items.
- Scene video playback and playlist transitions received lifecycle and end-of-playback fixes.

## 🌍 Localization

- Added translations for the scene-random filter preference across supported locales.
- Added translations for the scene metadata visibility setting and reveal action across supported locales.
- Regenerated localization output for the new settings labels.

## 🔧 Technical Updates

- Consolidated GraphQL schema generation around `graphql/schema.graphql`.
- Generated GraphQL and Mockito outputs are no longer tracked in Git; build tooling recreates them when needed.
- Removed unused media widgets, data-mapping helpers, pagination mixins, and delegating scrape providers.
- Added `json_annotation` and refreshed dependency lockfiles.

## 🧪 Testing

- Added coverage for random navigation providers and page flows, playlist paging, settings primitives, media notification lifecycle, playback completion, responsive scene headers, and scene metadata visibility/alignment.
- Updated affected settings, player, saved-filter, and media-handler tests.
