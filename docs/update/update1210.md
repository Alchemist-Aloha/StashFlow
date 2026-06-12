# StashFlow v1.21.0

## ✨ New Features

*   **Scene Tools Hub**: Added a new **Tools** page that brings scene maintenance workflows together in one place, with quick entry points for **Scene Deduplication** and **Scene Tagger**.
*   **Scene Tagger**: Introduced a new Stash-box tagging workflow for scenes, including current-page and random-unorganized modes, saved filter preset support, pagination, richer scene metadata, and preview playback while you review matches.
*   **Scene Deduplication**: Added a dedicated duplicate-scene finder with configurable distance and duration thresholds, pagination, safe selection options, and visibility into scenes that are still missing perceptual hashes.
*   **Scene Media Details**: Scene details now include a dedicated media section with cover and preview support, plus a fullscreen cover viewer for easier inspection.
*   **Scene Deletion Choices**: Scene deletion now makes the outcome explicit, letting you choose between removing only metadata or deleting the underlying files as part of the same confirmation flow.

## 🎨 UI & UX Improvements

*   **Preview Autoplay**: Scene previews in the new media section can autoplay to make quick review flows faster.
*   **Better Image Retry Behavior**: Fullscreen image loading failures now present a more accessible retry target instead of a plain gesture-only fallback.
*   **Playback Defaults**: Double-tap seek is now disabled by default in playback settings, matching the updated player interaction model.
*   **Scene List Performance**: List and grid rendering work was tightened up to reduce unnecessary per-frame work during fast scrolling.

## 🛠 Under the Hood

*   **Cache Handling**: GraphQL cache storage now lives in temporary storage, with improved cleanup for legacy cache locations and more detailed cache-size logging.
*   **Cache Enforcement**: Cache limit enforcement now reports how much data existed, how much was removed, and how many files or scan errors were involved.
*   **Scene Scraping**: Scene scraping and tagging logic now handles image normalization and no-cache fetch behavior more robustly.
*   **Repository Updates**: Added backend support for duplicate-scene queries and scene destruction mutations, along with the corresponding test coverage.

## 🌍 Localization

*   **Expanded Translations**: Added and refreshed localization strings for the new tools, media sections, deletion flow, and updated playback settings.

