## 2024-05-24 - Throttling Pagination & Hoisting Lookups
**Learning:**
- Scroll events trigger `NotificationListener<ScrollNotification>` multiple times per frame. If `shouldLoadNextPage` remains true while waiting for async state to update, it creates redundant method calls.
- InheritedWidget lookups (like `GoRouter.of(context)`) inside an `itemBuilder` scale at O(N) complexity during layout.
**Action:**
- Throttle high-frequency pagination events (e.g., limit execution to once per 500ms using `DateTime` diffs).
- Always hoist invariant layout or routing variables out of loops and builders to the top of the `build` method.
