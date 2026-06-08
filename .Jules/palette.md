## 2024-05-18 - [Accessible Failed Image Reload]
**Learning:** Replaced a raw `GestureDetector` with `Semantics` and `InkWell` to provide both screen-reader accessibility and visual touch feedback (ripple) for interactive error states, conforming to the <50 line UX polish goal while avoiding lockfile regressions.
**Action:** Always wrap purely interactive elements in `Material` and `InkWell` with `Semantics` instead of using raw `GestureDetector`s, and ensure scratchpad scripts are cleaned up before committing.
