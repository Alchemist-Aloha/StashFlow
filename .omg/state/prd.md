## Stage
- team-prd

## Problem Statement
Many interactive elements, particularly `IconButton`s, currently lack `tooltip` properties. This degrades accessibility for screen reader users and users navigating via keyboard or hover on desktop/tablet views.

## Scope / Non-goals
### Scope
- **Tooltips**: Add localized or semantically appropriate `tooltip` attributes to all `IconButton`s and `FloatingActionButton`s across the `lib/` directory.

### Non-goals
- Full ADA compliance audit.
- Adding semantic labels to non-interactive widgets.

## Acceptance Criteria
| Criterion | Task ID(s) | Priority | Evidence Needed | Owner |
| --- | --- | --- | --- | --- |
| **All Buttons Tooltipped** | A1 | p0 | `grep_search` for `IconButton` confirms tooltips exist. | omg-product |

## Constraints
- **Localization**: Use `context.l10n` where appropriate. If a localized string doesn't exist, either add it or use a clear semantic English string with a TODO for localization.

## Baseline Expectations
- **Branch**: `dev`
- **HEAD**: `HEAD` (Clean analysis baseline).

## Handoff Contract
- **Lane**: `omg-executor`
- **Baseline**: `HEAD`
- **Evidence**: Successful `flutter build apk` and no new warnings.
