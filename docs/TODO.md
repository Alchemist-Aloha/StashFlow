# Roadmap & TODO

## Short-term Goals

- [x] In scene details fullscreen view, swipe back returns to scene list/details.
- [x] Add rating UI widget and backend mutation support.
- [ ] **System integration:** Connect video playback to android system video api.
- [ ] **Infinite scroll improvement:** 
    - long press swipe up to speed up more
    - send watched after 5 seconds to graphql server

## Recently Completed (2026-03-25)

- [x] **Tablet Optimization**: Adaptive navigation (sidebar) and responsive grid layouts.
- [x] **Performers UI**: 3/5 column grid with non-stretching circular thumbnails.
- [x] **Adaptive Grid**: Customizable column counts in `ListPageScaffold`.

## Recently Completed (2026-03-20)

- [x] Dedicated `/fullscreen/:id` route for robust navigation.
- [x] Global toggle for "Random" discovery buttons.
- [x] Dynamic "Playlist" strategy (Play Next follows current sequence).
- [x] Advanced sorting/filtering for Performers, Studios, and Tags.



## Long-term Goals

- [ ] **Extended Scraping:** Implement metadata scraping functionality for Performers and Studios.
- [ ] **Batch Operations:** Develop batch scraping capabilities for updating multiple items simultaneously.
- [x] **Playlist Strategy:** Implemented dynamic query sequence for "Play Next".
- [ ] **Playback Queue Fixes:** Investigate and fix the "Play Next" logic to ensure reliable transitions between scenes in the manual queue.