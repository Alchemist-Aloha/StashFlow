# StashFlow v1.23.0

## ✨ New Features

### Scene Details and Markers

- Scene details now keep the primary actions in the main info area instead of the app bar, with edit and scrape actions always visible.
- The inline player has a proper back control, and scene markers now have a dedicated browse page with saved filter support.

### Groups and Entity Browsing

- Groups are now a first-class browse section with details and media pages, and the tab remains hidden by default until enabled in Customize Tabs.
- Performer, studio, tag, gallery, and image pages now use page-specific sort and filter defaults instead of sharing the main scene defaults.

### Playback and Diagnostics

- Cast operations now emit structured process logging through `AppLogStore` when debug logging is enabled, which makes discovery and session issues easier to trace.

## 🎨 UI & UX Improvements

- Sort and filter sheets were standardized across the library, with shared bottom-sheet chrome and more consistent action layouts.
- The scene details view was refreshed around the rating/O-counter row and inline player controls, keeping playback actions and metadata actions in one place.
