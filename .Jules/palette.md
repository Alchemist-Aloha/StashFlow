## 2024-05-18 - [Accessible Failed Image Reload]
**Learning:** Replaced a raw `GestureDetector` with `Semantics` and `InkWell` to provide both screen-reader accessibility and visual touch feedback (ripple) for interactive error states, conforming to the <50 line UX polish goal while avoiding lockfile regressions.
**Action:** Always wrap purely interactive elements in `Material` and `InkWell` with `Semantics` instead of using raw `GestureDetector`s, and ensure scratchpad scripts are cleaned up before committing.

## 2024-06-14 - [Accessible Long Press Action on Title]
**Learning:** Found a hidden interaction (`GestureDetector` on `AppBar` title for long-press stats) and replaced it with a `Tooltip` and `InkWell` wrapped in a transparent `Material`. This significantly improves discoverability for hidden long-press actions by adding an accessible tooltip (useful for desktop hover) and visual touch feedback (ripple) without breaking the layout.
**Action:** When creating hidden long-press actions, wrap them in `Tooltip` and `InkWell` rather than a raw `GestureDetector` to provide better discoverability and touch feedback.
