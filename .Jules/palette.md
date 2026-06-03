## 2026-06-03 - Localized Tooltips
**Learning:** Found several floating action buttons and icon buttons using hardcoded English strings ('Saved filters') for their tooltips. Hardcoded strings harm accessibility for non-English screen reader users.
**Action:** When working on tooltips, always grep for hardcoded strings and map them to `context.l10n` keys to ensure translations apply properly.
