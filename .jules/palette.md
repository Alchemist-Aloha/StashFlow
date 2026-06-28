## 2024-06-28 - Add localized semanticsLabel to CircularProgressIndicator
**Learning:** In this app, many loading indicators were hardcoded as `const CircularProgressIndicator()` which prevented screen readers from identifying them.
**Action:** Always add `semanticsLabel: context.l10n.common_loading` and remove `const` from the widget tree to allow dynamic context access.
