# StashFlow v1.23.0

## ✨ New Features

### Scene Markers
- Scene markers now have a dedicated browse page with full filter and saved filter support.
- Markers display on a dedicated card view, and marker strings have been extracted to ARB localization.

### Entity Gallery Images
- Performer, studio, and tag detail pages now show images from their associated galleries via a new media grid.
- Gallery images are fetched with `networkOnly` fetch policy to ensure fresh data, scoped through gallery associations.
- A new **Entity Image Filter Method** setting lets users choose how entity images are displayed: from all galleries or filtered through a specific gallery.

### Groups
- Groups are now available as a hidden browse tab (disabled by default, enable in Customize Tabs).
- Group details page includes media grid and saved filter dialog with configuration management.
- Official groups filter support added.

### Image Filter Panel — Gallery Search
- The Gallery filter in the Image Filter panel now works correctly — the entity picker populates with gallery results and supports search.

### Cast Debug Logging
- Cast operations emit structured process logging through `AppLogStore` when debug logging is enabled, making discovery and session issues easier to trace.

## 🎨 UI & UX Improvements

- **Bottom Sheet Standardization**: Shared bottom-sheet chrome (`BottomSheetPanelHeader`, `BottomSheetPanelActions`) and a consistent `FilterBottomSheetScaffold` applied across all library page filter and sort sheets.
- **Scene Details Redesign**: Scene details layout reorganized — primary actions kept in the main info area rather than the app bar, edit and scrape actions always visible, inline player controls with proper back navigation, and a top gradient overlay for both inline and fullscreen video controls.
- **Sort & Filter Sheets**: All library pages (scenes, studios, performers, tags, galleries, images) now use unified sort/filter bottom sheets with consistent action layouts.
- **Interface Settings Reorganized**: Settings page restructured for clarity, with new layout options for scene markers and group media grids with persistence.
- **Scene Card VTT Scrubbing**: VTT availability is now verified asynchronously with a state-machine approach (unknown → checking → available/unavailable). Scrubbing preview only activates after VTT is confirmed valid, preventing incorrect time display during verification.
- **Performer Card Polish**: Performer cards now use `ClipRRect` with 12px rounded corners instead of `ClipOval`, with proper portrait aspect ratio and consistent sizing.
- **Performer Grid Columns**: Performer list section in Interface Settings now always shows its grid columns slider with a dedicated "Performers Grid Columns" label.

## 🐛 Bug Fixes

- Fixed gallery entity picker returning empty results in the Image Filter panel (missing `'gallery'` case in `EntityPicker`).
- Fixed `DropdownButtonFormField` to properly use `initialValue` for missing or empty values.
- Updated media notification handling and cleanup for scene cover images.
- Fixed `EntityPicker` using `title` for gallery items — now uses `displayName` to match other entity types.
- Fixed `const` context errors on `InputDecoration` when using localized labels in scene details and group filter panels.

## 🌐 Localization

- Hardcoded marker strings extracted to ARB files across all supported languages (en, de, es, fr, it, ja, ko, ru, zh).
- Added new ARB keys `auto_marker_name` ("Marker name") and `auto_missing_field` ("Missing Field") for scene marker creation and group filter dropdown labels.
- Localized remaining hardcoded strings in scene details (delete help text, marker creation/deletion snackbar messages) and group filter panel across all target locales.

## 🔧 Technical Updates

- `safe_local_storage` updated to v2.0.4.
- Removed unused dependencies; updated dependencies for compatibility.
- `scrape_customization_provider` removed following scene scrape preference streamlining.
- Various code refactors for readability and maintainability.
- Added widget tests for performer card rounded corners, performer page grid aspect ratio, performer list grid columns setting, and VTT availability state transitions.
- Scene card VTT state refactored from a simple boolean to a typed `_VttAvailability` enum for clearer state management.
