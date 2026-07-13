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
- Updated scene header controls and fullscreen playback controls, including random navigation access.

## 🛡️ Playback & Stability

- Android media notifications now stay synchronized with playback state and are dismissed when playback ends.
- Playback completion callbacks are edge-triggered to prevent duplicate queue advancement.
- Artwork updates are guarded against stale media items.
- Scene video playback and playlist transitions received lifecycle and end-of-playback fixes.

## 🌍 Localization

- Added translations for the scene-random filter preference across supported locales.
- Regenerated localization output for the new settings labels.

## 🔧 Technical Updates

- Consolidated GraphQL schema generation around `graphql/schema.graphql`.
- Generated GraphQL and Mockito outputs are no longer tracked in Git; build tooling recreates them when needed.
- Removed unused media widgets, data-mapping helpers, pagination mixins, and delegating scrape providers.
- Added `json_annotation` and refreshed dependency lockfiles.

## 🧪 Testing

- Added coverage for random navigation providers and page flows, playlist paging, settings primitives, media notification lifecycle, playback completion, and responsive scene headers.
- Updated affected settings, player, saved-filter, and media-handler tests.
