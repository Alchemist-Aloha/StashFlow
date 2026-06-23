## 2024-05-24 - Add SemanticsLabel to CircularProgressIndicator
**Learning:** In Flutter, `CircularProgressIndicator` doesn't automatically announce itself to screen readers. Relying solely on the visual indicator excludes visually impaired users. By providing a `semanticsLabel`, screen readers can correctly announce the loading state.
**Action:** Always add a localized `semanticsLabel` to `CircularProgressIndicator` instances. Remember that doing so requires dynamic context access, so you'll need to remove `const` modifiers from parent widgets where necessary.
## 2024-06-23 - Add explicit button semantics to SceneCard
**Learning:** Flutter's `InkWell` does not automatically provide a localized or clear accessibility label for complex compound widgets like a `SceneCard` that relies on internal `Text` children. Adding an explicit `Semantics(button: true, label: ...)` wrapper drastically improves context for screen reader users by turning the whole element into a single announced button target.
**Action:** Always wrap interactive list/grid cards with a `Semantics` label containing the primary title or action.
