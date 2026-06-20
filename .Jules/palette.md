## 2024-05-24 - Add SemanticsLabel to CircularProgressIndicator
**Learning:** In Flutter, `CircularProgressIndicator` doesn't automatically announce itself to screen readers. Relying solely on the visual indicator excludes visually impaired users. By providing a `semanticsLabel`, screen readers can correctly announce the loading state.
**Action:** Always add a localized `semanticsLabel` to `CircularProgressIndicator` instances. Remember that doing so requires dynamic context access, so you'll need to remove `const` modifiers from parent widgets where necessary.
## 2024-05-15 - Improve checkbox tap target accessibility
**Learning:** Combining a `Checkbox` and `Text` widget inside a `Row` creates tiny tap targets that are hard to hit on mobile screens and often lack proper semantic association for screen readers.
**Action:** Always prefer using `CheckboxListTile` (or `SwitchListTile.adaptive` for toggles) instead. This natively associates the label with the input, expands the tap area to the full row, and significantly improves both usability and accessibility.
