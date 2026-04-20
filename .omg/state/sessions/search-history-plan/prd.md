# Product Requirements Document (PRD): Material 3 SearchAnchor with History

## Problem Statement
The current `ListPageScaffold` uses an inline `TextField` for search, which lacks a persistent search history and does not align with the modern Material 3 `SearchAnchor` design pattern. Users need a way to easily access their recent searches per page (e.g., Scenes, Performers), re-execute them, and manage their search history (delete individual items or clear all) to improve navigation and search efficiency.

## Scope and Non-goals

**Scope:**
- Replace the inline `TextField` in the `ListPageScaffold` AppBar with a Material 3 `SearchAnchor` widget.
- Implement a persistent search history using `SharedPreferences` via a Riverpod state notifier (`SearchHistoryNotifier`).
- Ensure search history is scoped per page (e.g., separate history for Scenes, Performers, Studios, Tags).
- Limit the search history to a maximum of 20 items per page.
- Provide UI within the `SearchAnchor` suggestions to delete individual history items (e.g., a trailing 'x' button).
- Provide a "Clear All" or "Clear History" option within the suggestions view.
- Localize all new UI text strings.
- Ensure the layout remains responsive and does not break across mobile and desktop breakpoints.

**Non-goals:**
- Modifying or replacing the global search logic (search must remain scoped to the specific page/tab).
- Implementing complex fuzzy matching for history suggestions (exact prefix or simple substring matching is sufficient if any, otherwise just show chronological history).
- Creating or interacting with a backend API for search history (history is strictly local).

## Acceptance Criteria
1. **UI Update:** The `ListPageScaffold` AppBar displays a Material 3 `SearchAnchor` instead of a standard `TextField`.
2. **Persistence & Scope:** Executing a search saves the query to local `SharedPreferences`. The history is strictly isolated by page context (e.g., searching in Scenes does not pollute Performers' history).
3. **Suggestion List:** Tapping the search bar displays the recent search history (up to 20 items) for that specific page.
4. **Item Deletion:** Users can delete an individual search history item by tapping a trailing 'x' icon on the suggestion tile. The item is immediately removed from the UI and persistence.
5. **Clear All:** Users can tap a "Clear All" (or similar) button in the search view to wipe the entire search history for the current page context.
6. **Localization:** New text strings (e.g., "Clear All") are added to `.arb` files and render correctly in the UI.
7. **Responsiveness:** The `SearchAnchor` integrates cleanly into the AppBar, adapting properly to both narrow (mobile) and wide (tablet/desktop) screen sizes without overflow or rendering errors.
8. **Resource Management:** `SearchController` is properly initialized, synchronized with `widget.onSearchChanged`, and disposed of to prevent infinite loops or memory leaks.

## Constraints and Dependencies
- **Technical Constraints:**
  - Must utilize the Material 3 `SearchAnchor` widget.
  - State management and dependency injection must use Riverpod.
  - Persistence must use the existing `SharedPreferences` implementation.
- **Dependencies:**
  - `SEARCH-02` (UI implementation) depends on `SEARCH-01` (State and Persistence implementation).
  - `SEARCH-03` (Localization and Polish) depends on `SEARCH-02`.
- **Risks & Mitigations:**
  - *Layout breaking:* Test extensively on mobile and desktop breakpoints to ensure `SearchAnchor` actions don't push other AppBar actions out of bounds.
  - *State mismatch/Memory leaks:* Carefully manage the lifecycle of `SearchController` within the widget state, ensuring it aligns with external search state updates without circular reactivity.
  - *History Pollution:* Strictly enforce the `storageKey` parameter when creating instances of the `SearchHistoryNotifier` so each list page gets an isolated storage bucket.
