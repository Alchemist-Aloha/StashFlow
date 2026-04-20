## Stage
- team-plan

## Goal / Non-goals
- **Goal:** Implement a Material 3 `SearchAnchor` widget in `ListPageScaffold` replacing the inline `TextField`, complete with persistent search history (stored via SharedPreferences), individual item deletion, and a "clear all" function.
- **Non-goals:** Modifying the global search logic (search remains scoped to the specific page/tab), complex fuzzy matching of history, creating a backend API for search history.

## Task Graph
| Task ID | Priority | Task | Owner | Dependency | Path Type | Worktree | Baseline | Lane Notes | Validation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SEARCH-01 | p1 | Create `SearchHistoryNotifier` for Riverpod state and persistence using `SharedPreferences`. | omg-executor | none | critical-path | Workspace | HEAD | Implement `addQuery`, `removeQuery`, and `clearAll` methods. Limit history size to 20. Use a `storageKey` (e.g. 'scenes') so history is page-specific. | Verify provider loads and updates SharedPreferences correctly. |
| SEARCH-02 | p1 | Replace `TextField` with `SearchAnchor` in `ListPageScaffold` AppBar. | omg-executor | SEARCH-01 | critical-path | Workspace | HEAD | Bind `SearchAnchor` to the new provider. Implement `suggestionsBuilder` with history list, delete individual items (trailing x button), and "Clear All" option. | Type query, submit, verify it appears in suggestions. Click 'x' to remove, test 'Clear All'. |
| SEARCH-03 | p2 | Add Localization and Polish UI layout. | omg-executor | SEARCH-02 | sequential | Workspace | HEAD | Add translation keys for "Clear History" or similar text. Ensure layout handles mobile/desktop boundaries cleanly. | Test responsive layout and translations. |

## Critical Files
- `lib/core/data/preferences/search_history_provider.dart` (New)
- `lib/core/presentation/widgets/list_page_scaffold.dart`
- `lib/core/data/preferences/shared_preferences_provider.dart`
- `l10n/app_en.arb` (and other translation files as needed)

## Risks
- **Layout breaking:** Replacing `TextField` with `SearchAnchor` might alter how the AppBar renders actions on different screen sizes (desktop vs. mobile breakpoints).
- **State mismatch:** Making sure `SearchController` is properly disposed or synchronized with `widget.onSearchChanged` to avoid infinite loops or memory leaks.
- **Search History Scope:** We must scope search history per page (e.g., Scenes vs Performers) to avoid polluting suggestions, which requires parameterizing the provider based on the list context.

## Taskboard Sync
- Written to `.omg/state/sessions/search-history-plan/taskboard.md` (pending merge since no session lock was found).

## Ready For team-prd
- Yes. Proceed with `/omg:team-prd --intent="implement Material 3 SearchAnchor with history in ListPageScaffold"`