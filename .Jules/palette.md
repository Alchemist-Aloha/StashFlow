## 2024-05-18 - Replacing raw GestureDetectors on purely interactive UI icons with IconButton/InkWell
**Learning:** Raw `GestureDetector` wrapping an `Icon` lacks semantic context, focusability, and touch feedback.
**Action:** Always prefer native Flutter components like `IconButton` or `InkWell` + `Semantics` which provide ripple effects, hover states, and keyboard navigation support out of the box.
