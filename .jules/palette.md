## 2024-06-25 - Replace raw GestureDetector with accessible Tooltip+Material+InkWell\n**Learning:** When creating interactive UI elements for hidden/inline text, replacing a raw `GestureDetector` with an `InkWell` wrapped inside a `Material` (with `Colors.transparent`) and `Tooltip` adds visual touch feedback (ripple), ensures keyboard focusability, and provides crucial screen-reader accessibility, satisfying core Flutter UX guidelines.\n**Action:** Prioritize native semantic components (`Tooltip`, `InkWell`) over raw `GestureDetector` for purely interactive elements that lack visual feedback.

## 2024-05-18 - Improve tap target of Checkbox settings
**Learning:** Raw `Checkbox` wrapped in a `Row` with a `Text` widget creates a tiny tap target for mobile users and poor semantics for screen readers.
**Action:** Use native `CheckboxListTile` (or `SwitchListTile`) which automatically expands the tap area to the full row width and natively associates the label.
