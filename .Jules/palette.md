## 2024-05-24 - Add SemanticsLabel to CircularProgressIndicator
**Learning:** In Flutter, `CircularProgressIndicator` doesn't automatically announce itself to screen readers. Relying solely on the visual indicator excludes visually impaired users. By providing a `semanticsLabel`, screen readers can correctly announce the loading state.
**Action:** Always add a localized `semanticsLabel` to `CircularProgressIndicator` instances. Remember that doing so requires dynamic context access, so you'll need to remove `const` modifiers from parent widgets where necessary.
