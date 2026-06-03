## 2024-05-18 - Replacing Raw GestureDetector Text Links with Semantics and InkWell
**Learning:** Found that custom plain text links used for navigation (like clicking on a Studio name to open its details) were wrapped in a basic `GestureDetector` without providing accessibility roles, hover states, or touch feedback. This makes them invisible to screen readers as interactive elements and feels "dead" to touch or mouse interaction.
**Action:** Replaced the `GestureDetector` wrapper with `Semantics(button: true)` + `Material` + `InkWell`. By adding a small `padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1)` to the `InkWell`, it gives the ripple animation room to breathe while keeping the layout footprint minimal.
## 2024-05-18 - Replacing GestureDetector + Icon with IconButton
**Learning:** In Flutter, `GestureDetector` combined with `Container` and `Icon` doesn't provide visual accessibility feedback (like splash ripples) and lacks semantic button properties.
**Action:** Replace `GestureDetector` + `Icon` combinations with native `IconButton` widgets wherever simple button tap logic is required, restoring full accessibility, keyboard focus support, and native tooltips.
