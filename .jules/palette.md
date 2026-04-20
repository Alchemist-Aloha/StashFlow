## 2025-02-28 - Tooltips for Dynamic State Toggles
**Learning:** In Flutter, adding a `tooltip` to an `IconButton` automatically sets its semantic accessibility label for screen readers. For dynamic state toggles like password visibility (`_obscurePassword`), the tooltip must conditionally update its text (e.g., 'Show password' vs 'Hide password') to maintain accurate screen reader announcements matching the visual state.
**Action:** When adding or reviewing tooltips on toggle buttons, always ensure the tooltip text dynamically reflects the active state rather than using a static label.
## 2024-05-19 - Localized Icon Tooltips
**Learning:** Hardcoded strings in Flutter tooltips bypass localization mechanisms and result in inconsistent accessibility labeling for screen readers. In `stash_app_flutter`, `IconButton.tooltip` maps to ARIA labels.
**Action:** Always verify `tooltip` strings use `context.l10n.[key]` rather than literal strings, and proactively sweep UI files (e.g., list pages and details pages) for typoed or hardcoded tooltips to maintain semantic a11y.
