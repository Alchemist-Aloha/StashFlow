## 2026-04-26 - Found un-labelled Icon-Only Button
**Learning:** Found an `IconButton` in `SceneInfoPage` that had no `tooltip` property. Icon-only buttons without tooltips are completely opaque to screen readers and also miss native desktop hover hints.
**Action:** Always add the `tooltip` parameter to `IconButton` when it only contains an `Icon` widget. This serves as the semantic label and desktop hover text.
