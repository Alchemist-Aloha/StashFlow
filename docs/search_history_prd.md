# Product Requirements Document: Search History & Auto-Submit

## Problem Statement
The current implementation of `SearchAnchor` in `ListPageScaffold` filters history based on the active search input, preventing users from browsing their full history when the input is empty or when they want to see all previous queries. Additionally, closing the search view via swipe/back-gesture does not persist partial search queries, forcing users to manually re-type.

## Scope
- **In-Scope**: 
    - Update `suggestionsBuilder` to display full search history when input is empty.
    - Implement auto-submission on search view dismissal if the current text has changed since the last query.
- **Out-of-Scope**: 
    - Changes to search history persistence logic (e.g., adding/clearing).
    - UI styling changes beyond functional requirements.

## Acceptance Criteria
- [ ] **Full History Display**: Opening the search view displays the full recent search history even when the search input is empty.
- [ ] **Auto-Submit on Close**: If a user types text and closes the search view (back-gesture/swipe), the search query triggers `widget.onSearchChanged`.
- [ ] **Data Integrity**: 
    - Prevent duplicate submissions.
    - Handle empty queries correctly.
    - Verify search state matches modified input.
- [ ] **Responsiveness**: No performance regressions or UI loops.

## Constraints & Dependencies
- Must utilize existing `searchHistoryProvider`.
- Must not conflict with existing `viewOnSubmitted` handler.
- Compatibility with `flutter` search framework `SearchAnchor` and `SearchController`.

## Handoff Checklist
- [ ] `lib/core/presentation/widgets/list_page_scaffold.dart` updated to handle `onClosed` logic.
- [ ] `suggestionsBuilder` logic updated to ignore filter if `controller.text.isEmpty`.
- [ ] Verification of dismissal behavior in integration tests.
