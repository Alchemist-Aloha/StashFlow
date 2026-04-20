# PRD: Search Keyword Notice and Reactive Search History Refresh

## 1. Problem Statement
The current search implementation suffers from two key issues:
1. **Stale Search History:** The `SearchAnchor` does not reactively rebuild its suggestion list when history is modified (deleted or cleared), leading to stale UI state.
2. **Lack of Search Visibility:** Users lack an explicit, persistent UI indicator of their currently active search query while browsing list results, making it difficult to understand the context of the displayed items.

## 2. Scope and Non-Goals
### Scope
- Implement a reactive mechanism to update `SearchAnchor` suggestions upon history mutation.
- Add a persistent search keyword notice component under the `AppBar` in `ListPageScaffold` when a search is active.
- Ensure the notice supports a "Clear Search" action.
- Ensure responsive layout compatibility for mobile and tablet views.

### Non-Goals
- Adding persistent database-backed search history (existing infrastructure assumed).
- Modifying the underlying GraphQL search implementation or server-side filtering.
- Introducing a new global state management library (use existing architecture).

## 3. Acceptance Criteria
1. **Reactive History:** `SearchAnchor` suggestions update immediately (rebuild) upon deletion of a single history item or clearing the entire history list.
2. **Keyword Visibility:** A Chip or Banner component appears directly below the `AppBar` within `ListPageScaffold` when a search query is active (`query.isNotEmpty`).
3. **Clear Search Action:** The keyword notice must contain an 'X' or 'Clear' button that, when pressed, resets the search query and removes the notice.
4. **Layout Integrity:** The addition of the search notice must not interfere with `ListPageScaffold` layout (e.g., no unexpected padding or overflow) across different screen sizes (mobile/tablet/desktop).

## 4. Constraints and Dependencies
- **Architecture:** Must follow the existing Flutter architecture for list screens (`ListPageScaffold`).
- **Dependencies:** Leverages current state management for filter/search updates.
- **Performance:** UI updates must be instantaneous (avoid noticeable lag in `SearchAnchor`).

## 5. Handoff Checklist
- [ ] Identify `SearchAnchor` implementation in `lib/features/`.
- [ ] Determine how to propagate history changes to `SearchAnchor` rebuild.
- [ ] Design/Select UI component (Chip vs. Banner) for `ListPageScaffold`.
- [ ] Implement clear-search callback integration.
- [ ] Verify layout responsiveness in integration tests.
