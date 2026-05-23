## 2026-04-26 - Found un-labelled Icon-Only Button
**Learning:** Found an `IconButton` in `SceneInfoPage` that had no `tooltip` property. Icon-only buttons without tooltips are completely opaque to screen readers and also miss native desktop hover hints.
**Action:** Always add the `tooltip` parameter to `IconButton` when it only contains an `Icon` widget. This serves as the semantic label and desktop hover text.
## 2024-05-19 - Localize tooltips
**Learning:** Hardcoded strings in `tooltip` properties of interactive elements like `IconButton` break localization and make the app less accessible to international users, especially for those using screen readers. `IconButton` components use the `tooltip` property not only to display a popup on hover but also to provide the semantic label for accessibility purposes.
**Action:** Always verify if a tooltip string can be linked to an existing localization key via `context.l10n`. If none exists, add one to `lib/l10n/app_en.arb` and generate the localization bindings using `flutter gen-l10n`. Never use hardcoded strings for tooltips or semantic labels.

## 2024-05-18 - Fullscreen Raw Image Semantics
**Learning:** Screen readers may redundantly announce "Image" or attempt to read the raw URL data for decorative/fullscreen raw image viewers like `ExtendedImage.network` if no semantic label is provided, trapping focus on unhelpful content.
**Action:** Always add `excludeFromSemantics: true` to purely decorative or context-less fullscreen images (especially those fetching raw URLs) to prevent unhelpful screen reader announcements.
