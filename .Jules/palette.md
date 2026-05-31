## 2024-05-18 - InkWell over GestureDetector for Text Links
**Learning:** Raw `GestureDetector`s lack visual feedback (ripple effect) and screen-reader accessibility when used for interactive UI elements.
**Action:** When creating purely interactive UI elements that trigger actions or navigation, avoid using a raw `GestureDetector`. Instead, wrap them in a `Material` widget (if missing) and use `InkWell` combined with `Semantics(button: true, label: ...)` to provide touch feedback, keyboard focusability, and screen-reader accessibility.
